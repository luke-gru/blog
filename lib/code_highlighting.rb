# frozen_string_literal: true
class CodeHighlighting
  class HTMLPygmentsSpanContainer < Rouge::Formatters::HTMLPygments
    def stream(tokens, &b)
      yield %Q(<span class="highlight highlight-inline"><span class="#{@css_class}">)
      @inner.stream(tokens, &b)
      yield "</span></span>"
    end
  end

  # The initial list of supported languages and how I want to name them.
  # This list can grow at runtime.
  SUPPORTED_LANGS = {
    "ruby" => :Ruby,
    "rb"   => :Ruby,
    "c"    => :C,
    "javascript" => :Javascript,
    "js" => :Javascript,
    "html" => :HTML,
    "css" => :CSS,
    "yaml" => :YAML,
    "yml" =>  :YAML,
    "json" => :JSON,
    "erb" => :ERB,
    "make" => :Make,
    "shell" => :Shell,
    "bash" => :Shell,
    "sh" => :Shell,
    "docker" => :Docker,
  }
  SUPPORTED_LANG_NAMES = SUPPORTED_LANGS.keys

  attr_reader :error, :num_substitutions

  RubySyntaxCheckFailure = Class.new(StandardError)

  def initialize(content, input_is_html_safe: false, check_ruby_syntax: true)
    @content = content
    @input_is_html_safe = input_is_html_safe
    @check_ruby_syntax = check_ruby_syntax
    @error = nil
    @num_substitutions = 0
  end

  # substitutes:
  # ```lang
  #   code here
  # ```
  # with HTML that has specific highlighting classes
  # @return String that is html safe (can call raw() on it)
  def substitute_code_templates
    cursor = @content
    content_buf = []
    # ex: replace ```ruby\nputs "HI"``` with proper pygment HTML tags
    while true
      if m = cursor.match(/```([\w()]+)\s*(.+?)```/m)
        inline_template = false
        lang, code_content = m.captures
        # allow ```ruby(inline) ActionController::Base.helpers```
        if lang.ends_with?("(inline)")
          inline_template = true
          lang = lang.sub("(inline)", "")
        end
        if @input_is_html_safe
          # trix used to add these, not sure if needed now because trix is no longer used
          code_content.gsub!(/<br>/, '')
        end
        code_content = sanitize_code(code_content)
        orig_lang = lang
        lang = lang.downcase
        if lang == "ruby" && @check_ruby_syntax
          Tempfile.create("code_content") do |f|
            f.write code_content
            f.flush
            # TODO: capture stderr and put it in error message
            system("#{RbConfig.ruby} -c #{f.path} > /dev/null 2>&1")
            unless $?.exitstatus == 0
              raise RubySyntaxCheckFailure, code_content
            end
          end
        end
        lexer = if lang.in?(SUPPORTED_LANG_NAMES)
          Rouge::Lexers.const_get(SUPPORTED_LANGS[lang]).new
        # ex: ```Kotlin or ```kotlin
        elsif (found = (Rouge::Lexers.const_get(lang.capitalize) rescue nil)) &&
               found < Rouge::Lexer
          SUPPORTED_LANGS[lang] = lang.capitalize.intern
          SUPPORTED_LANG_NAMES << lang
          found.new
        # ex: ```LLVM
        elsif (found = (Rouge::Lexers.const_get(orig_lang) rescue nil)) &&
               found < Rouge::Lexer
          SUPPORTED_LANGS[orig_lang] = orig_lang.intern
          SUPPORTED_LANG_NAMES << orig_lang
          found.new
        else
          @error = "Unable to parse language '#{lang}'"
          return
        end
        beg_match_before, _end_match_before = m.offset(0)
        _beg_match_code, end_match_code = m.offset(2)
        before_content = cursor[0...beg_match_before]
        before_content = html_escape(before_content)
        html_formatter = Rouge::Formatters::HTML.new
        if inline_template
          formatter = HTMLPygmentsSpanContainer.new(html_formatter)
        else
          formatter = Rouge::Formatters::HTMLPygments.new(html_formatter)
        end
        code_content = formatter.format(lexer.lex(code_content))

        new_content = before_content + code_content
        #nl_without_cr = /(?<!\r)\n/
        #new_content.gsub!(nl_without_cr, "\r\n")
        content_buf << new_content
        cursor = cursor[end_match_code+3..-1] # +3 for ```
        @num_substitutions += 1
        break if cursor.empty?
      else
        break
      end
    end

    content_buf << html_escape(cursor) unless cursor.empty?

    content_buf.join
  end

  private

  HELPERS = ActionController::Base.helpers

  def html_escape(string)
    if @input_is_html_safe
      string
    else
      HELPERS.escape_once(string).to_str
    end
  end

  CODE_SCRUBBER = Loofah::Scrubber.new do |node|
    case node.name
    when "text"
      # do nothing
    else
      node.remove
    end
  end

  def sanitize_code(code_content)
    if @input_is_html_safe
      code_content
    else
      HELPERS.sanitize(code_content, scrubber: CODE_SCRUBBER).to_str
    end
  end
end
