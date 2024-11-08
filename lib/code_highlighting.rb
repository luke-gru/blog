# frozen_string_literal: true
class CodeHighlighting

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
  
  def initialize(content, input_is_html_safe: false)
    @content = content
    @input_is_html_safe = input_is_html_safe
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
      if m = cursor.match(/```(\w+)\s*(.+?)```/m)
        lang, code_content = m.captures
        if @input_is_html_safe
          # trix used to add these, not sure if needed now because trix is no longer used
          code_content.gsub! /<br>/, ''
        end
        code_content = sanitize_code(code_content)
        orig_lang = lang
        lang = lang.downcase
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
        beg_match_before, end_match_before = m.offset(0)
        _beg_match_code, end_match_code = m.offset(2)
        before_content = cursor[0...beg_match_before]
        before_content = html_escape(before_content)
        html_formatter = Rouge::Formatters::HTML.new
        formatter = Rouge::Formatters::HTMLPygments.new(html_formatter)
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
