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
    refute_match(/```/, result)
  end

  def test_ruby_code_gets_checked_for_syntax_by_default
    src = <<SRC
```ruby
puts "Hello, world!
```
SRC
    highlighting = CodeHighlighting.new(src, input_is_html_safe: true)
    assert_raises CodeHighlighting::RubySyntaxCheckFailure do
      highlighting.substitute_code_templates
    end
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
    refute_match(/```/, result)
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
    refute_match(/```/, result)
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
    refute_match(/```/, result)
  end

  def test_inline_code_template
    src = <<SRC
<p>Make sure to have a ```ruby(inline) ActionView::Helper``` class</p>
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: true)
    result = hl.substitute_code_templates
    assert_nil hl.error
    assert_replacements(result, 1, container_element: "span")
    refute_match(/```/, result)
  end

  def test_inline_bug
    src = <<SRC
<p>
We could create a helper method for formatting time in this example and either add that
method in the context class, pass a lambda into the input vars of the initializer or extend the context
object with a method after initialization. Let's say we want to access the `link_to` helper method to generate an `a`
tag. For that, we just need to include the proper module into the context class, in this case it's ```ruby(inline) ActionView::Helpers::UrlHelper```.
Want all the helper methods available to regular Rails templates? Include ```ruby(inline) ActionView::Helpers``` itself.
</p>
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: true)
    result = hl.substitute_code_templates
    assert_nil hl.error
    assert_replacements(result, 2, container_element: "span")
    refute_match(/```/, result)
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
    refute_match(/```/, result)
    refute_match(/<script>/, result)
    assert_match(/&lt;script/, result)
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
    refute_match(/```/, result)
    refute_match(/<script>/, result)
    refute_match(/&lt;script/, result)
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
    assert_match(/Unable to parse language/, hl.error)
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

  def test_parser_lang_multiple_capitals_not_hardcoded_but_found
    src = <<SRC
```LLVM
define double @foo(double %a, double %b) {
entry:
  %multmp = fmul double %a, %a
  %multmp1 = fmul double 2.000000e+00, %a
  %multmp2 = fmul double %multmp1, %b
  %addtmp = fadd double %multmp, %multmp2
  %multmp3 = fmul double %b, %b
  %addtmp4 = fadd double %addtmp, %multmp3
  ret double %addtmp4
}
```
SRC
    hl = CodeHighlighting.new(src, input_is_html_safe: true)
    result = hl.substitute_code_templates
    assert_nil hl.error
    assert_replacements result, 1
  end

  private

  def assert_replacements(result, num, container_element: "div")
    klass = "highlight"
    if container_element == "span"
      klass += " highlight-inline"
    end
    ce = container_element
    case num
    when 0
      refute_match(/<#{ce} class="#{klass}">/m, result)
    when 1
      assert_match(/<#{ce} class="#{klass}">/m, result)
      refute_match(/<#{ce} class="#{klass}">(.+?)<#{ce} class="#{klass}">/m, result)
    when 2
      assert_match(/<#{ce} class="#{klass}">(.+?)<#{ce} class="#{klass}">/m, result)
    else
      raise ArgumentError, "num should be 1 or 2, is: #{num}"
    end
  end
end
