class CodeHighlighting
  attr_reader :error

  def initialize(content)
    @content = content
    @error = nil
  end

  # substitutes:
  # ```lang
  # ```
  # with HTML with specific highlighting classes
  def substitute_code_templates
    # ex: replace ```ruby\nputs "HI"``` with proper pygment HTML tags
    if m = @content.match(/```(\w+)\s*(.+)```/m)
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
      beg_match, end_match = m.offset(0)
      before_content, after_content = [@content[0...beg_match], @content[end_match..-1]]
      html_formatter = Rouge::Formatters::HTML.new
      formatter = Rouge::Formatters::HTMLPygments.new(html_formatter)
      code_content = formatter.format(lexer.lex(code_content))

      new_content = before_content + code_content + after_content
      nl_without_cr = /(?<!\r)\n/
      new_content.gsub!(nl_without_cr, "\r\n")
      new_content
    end
  end
end
