# frozen_string_literal: true
class CodeHighlighting
  attr_reader :error

  def initialize(content)
    @content = content
    @error = nil
  end

  # FIXME: make it substitute ALL code templates, not just first
  #
  # substitutes:
  # ```lang
  # ```
  # with HTML with specific highlighting classes
  def substitute_code_templates
    cursor = @content
    content_buf = []
    # ex: replace ```ruby\nputs "HI"``` with proper pygment HTML tags
    while true
      if m = cursor.match(/```(\w+)\s*(.+?)```/m)
        lang, code_content = m.captures
        code_content.gsub! /<br>/, '' # trix used to add this, not sure if needed now
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
        else
          @error = "Unable to parse language '#{lang}'"
          return
        end
        beg_match_before, end_match_before = m.offset(0)
        beg_match_code, end_match_code = m.offset(2)
        before_content = cursor[0...beg_match_before]
        html_formatter = Rouge::Formatters::HTML.new
        formatter = Rouge::Formatters::HTMLPygments.new(html_formatter)
        code_content = formatter.format(lexer.lex(code_content))

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

    content_buf << cursor unless cursor.empty?

    content_buf.join
  end
end
