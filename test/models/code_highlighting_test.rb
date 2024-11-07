require "test_helper"

class CodeHighlightingTest < ActiveSupport::TestCase

  def test_no_templates_produces_same_output_as_input
    template = <<TEMPLATE
<p>Here's some HTML</p>
<p>And that's all...</p>
TEMPLATE
    highlighting = CodeHighlighting.new(template, input_is_html_safe: true)
    result = highlighting.substitute_code_templates
    assert_equal template, result
    assert_nil highlighting.error
  end

  def test_single_template_simple
    template = <<TEMPLATE
```ruby
puts "Hello, world!"
```
TEMPLATE
    highlighting = CodeHighlighting.new(template, input_is_html_safe: true)
    result = highlighting.substitute_code_templates
    assert_nil highlighting.error
    assert_replacements result, 1
    refute_match /```/, result
  end

  def test_single_template_with_surrounding_text
    template = <<TEMPLATE
<p>Here's some code:</p>
```ruby
puts "Hello, world!"
```
<p>And that's all...</p>
TEMPLATE
    highlighting = CodeHighlighting.new(template, input_is_html_safe: true)
    result = highlighting.substitute_code_templates
    assert_nil highlighting.error
    assert_replacements result, 1
    refute_match /```/, result
  end

  def test_two_templates_with_surrounding_text
    template = <<TEMPLATE
<p>Here's some code:</p>
```ruby
puts "Hello, world!"
```
<p>But that's not all...</p>
```ruby
puts "Goodbye!"
```
<p>Okay that's all now...</p>
TEMPLATE
    highlighting = CodeHighlighting.new(template, input_is_html_safe: true)
    result = highlighting.substitute_code_templates
    assert_nil highlighting.error
    assert_replacements result, 2
    refute_match /```/, result
  end

  def test_two_templates_in_a_row
    template = <<TEMPLATE
<p>Here's some code:</p>
```ruby
puts "Hello, world!"
```
```ruby
puts "Goodbye!"
```
<p>Okay that's all now...</p>
TEMPLATE
    highlighting = CodeHighlighting.new(template, input_is_html_safe: true)
    result = highlighting.substitute_code_templates
    assert_nil highlighting.error
    assert_replacements result, 2
    refute_match /```/, result
  end

  def test_template_not_html_safe_gets_escaped_outside_code
    template = <<TEMPLATE
<script>xssAttack()</script>
```ruby
  puts "You got owned"
```
TEMPLATE
    highlighting = CodeHighlighting.new(template, input_is_html_safe: false)
    result = highlighting.substitute_code_templates
    assert_nil highlighting.error
    assert_replacements result, 1
    refute_match /```/, result
    refute_match /<script>/, result
    assert_match /&lt;script/, result
  end

  def test_template_not_html_safe_gets_escaped_in_code
    template = <<TEMPLATE
```ruby
</pre><script>owned()</script>
```
TEMPLATE
    highlighting = CodeHighlighting.new(template, input_is_html_safe: false)
    result = highlighting.substitute_code_templates
    assert_nil highlighting.error
    assert_replacements result, 1
    refute_match /```/, result
    refute_match /<script>/, result
    refute_match /&lt;script/, result
  end

  def test_parser_for_lang_not_found_error
    template = <<TEMPLATE
```markdown
# Title
```
TEMPLATE
    highlighting = CodeHighlighting.new(template, input_is_html_safe: true)
    result = highlighting.substitute_code_templates
    refute_nil highlighting.error
    assert_nil result
    assert_match /Unable to parse language/, highlighting.error
  end

  private

  def assert_replacements(result, num)
    case num
    when 0
      refute_match /<div class="highlight">/m, result
    when 1
      assert_match /<div class="highlight">/m, result
      refute_match /<div class="highlight">(.+?)<div class="highlight">/m, result
    when 2
      assert_match /<div class="highlight">(.+?)<div class="highlight">/m, result
    else
      raise ArgumentError, "num should be 1 or 2, is: #{num}"
    end
  end
end
