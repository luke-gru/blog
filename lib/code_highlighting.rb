# frozen_string_literal: true
class CodeHighlighting
  attr_reader :error

  def initialize(content, input_is_html_safe: false)
    @content = content
    @input_is_html_safe = input_is_html_safe
    @error = nil
  end

  # substitutes:
  # ```lang
  # code here
  # ```
  # with HTML that has specific highlighting classes
  # @return String, that is html safe (can call raw() on it)
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
        code_content = sanitize_code(code_content).html_safe
        lang = lang.downcase
        lexer = case lang
        when "ruby"
          Rouge::Lexers::Ruby.new
        when "c"
          Rouge::Lexers::C.new
        when "js", "javascript"
          Rouge::Lexers::Javascript.new
        when "html"
          Rouge::Lexers::HTML.new
        when "css"
          Rouge::Lexers::CSS.new
        when "yaml", "yml"
          Rouge::Lexers::YAML.new
        when "json"
          Rouge::Lexers::JSON.new
        when "erb"
          Rouge::Lexers::ERB.new
        when "make"
          Rouge::Lexers::Make.new
        when "shell", "bash", "sh"
          Rouge::Lexers::Shell.new
        when "docker"
          Rouge::Lexers::Docker.new
        else
          @error = "Unable to parse language '#{lang}'"
          return
        end
        beg_match_before, end_match_before = m.offset(0)
        _beg_match_code, end_match_code = m.offset(2)
        before_content = cursor[0...beg_match_before]
        before_content = html_escape(before_content).html_safe
        html_formatter = Rouge::Formatters::HTML.new
        formatter = Rouge::Formatters::HTMLPygments.new(html_formatter)
        code_content = formatter.format(lexer.lex(code_content)).html_safe

        new_content = before_content + code_content
        nl_without_cr = /(?<!\r)\n/
        new_content.gsub!(nl_without_cr, "\r\n")
        content_buf << new_content
        cursor = cursor[end_match_code+3..-1] # +3 for ```
        break if cursor.empty?
      else
        break
      end
    end

    content_buf << html_escape(cursor).html_safe unless cursor.empty?

    content_buf.join
  end

  private
  include ActionView::Helpers::TagHelper # for escape_once, sanitize
  include ActionView::Helpers::SanitizeHelper # for sanitize

  def html_escape(string)
    if @input_is_html_safe
      string
    else
      escape_once(string)
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
      sanitize code_content, scrubber: CODE_SCRUBBER
    end
  end
end
