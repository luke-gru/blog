require "test_helper"

class CodeHighlightingTest < ActiveSupport::TestCase

  def test_no_code_templates_produces_same_output_as_input
    src = <<SRC
<p>Here's some HTML</p>
<p>And that's all...</p>
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: true)
    result = hl.substitute_code_templates
    assert_equal src, result
    assert_nil hl.error
  end

  def test_single_code_template_simple
    src = <<SRC
```ruby
puts "Hello, world!"
```
SRC
    highlighting = CodeHighlighting.new(src, input_is_html_safe: true)
    result = highlighting.substitute_code_templates
    assert_nil highlighting.error
    assert_replacements result, 1
    refute_match /```/, result
  end

  def test_single_code_template_with_surrounding_text
    src = <<SRC
<p>Here's some code:</p>
```ruby
puts "Hello, world!"
```
<p>And that's all...</p>
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: true)
    result = hl.substitute_code_templates
    assert_nil hl.error
    assert_replacements result, 1
    refute_match /```/, result
  end

  def test_two_code_templates_with_surrounding_text
    src = <<SRC
<p>Here's some code:</p>
```ruby
puts "Hello, world!"
```
<p>But that's not all...</p>
```ruby
puts "Goodbye!"
```
<p>Okay that's all now...</p>
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: true)
    result = hl.substitute_code_templates
    assert_nil hl.error
    assert_replacements result, 2
    refute_match /```/, result
  end

  def test_two_templates_in_a_row
    src = <<SRC
<p>Here's some code:</p>
```ruby
puts "Hello, world!"
```
```ruby
puts "Goodbye!"
```
<p>Okay that's all now...</p>
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: true)
    result = hl.substitute_code_templates
    assert_nil hl.error
    assert_replacements result, 2
    refute_match /```/, result
  end

  def test_not_html_safe_gets_escaped_outside_code
    src = <<SRC
<script>xssAttack()</script>
```ruby
  puts "You got owned"
```
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: false)
    result = hl.substitute_code_templates
    assert_nil hl.error
    assert_replacements result, 1
    refute_match /```/, result
    refute_match /<script>/, result
    assert_match /&lt;script/, result
  end

  def test_html_marked_not_html_safe_gets_removed_in_code
    src = <<SRC
```ruby
</pre><script>owned()</script>
```
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: false)
    result = hl.substitute_code_templates
    assert_nil hl.error
    assert_replacements result, 1
    refute_match /```/, result
    refute_match /<script>/, result
    refute_match /&lt;script/, result
  end

  def test_parser_for_lang_not_found_error
    src = <<SRC
```jfkdlsjlf
# Title
```
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: true)
    result = hl.substitute_code_templates
    refute_nil hl.error
    assert_nil result
    assert_match /Unable to parse language/, hl.error
  end

  def test_parser_lang_not_hardcoded_but_found
    src = <<SRC
```go
func main() {
    fmt.Println("hello world")
}
```
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: true)
    result = hl.substitute_code_templates
    assert_nil hl.error
    assert_replacements result, 1
  end

  private

  def assert_replacements(result, num)
    klass = "highlight"
    case num
    when 0
      refute_match /<div class="#{klass}">/m, result
    when 1
      assert_match /<div class="#{klass}">/m, result
      refute_match /<div class="#{klass}">(.+?)<div class="#{klass}">/m, result
    when 2
      assert_match /<div class="#{klass}">(.+?)<div class="#{klass}">/m, result
    else
      raise ArgumentError, "num should be 1 or 2, is: #{num}"
    end
  end
end
