require "test_helper"

class CodeHighlightingTest < ActiveSupport::TestCase

  def test_single_template_with_surrounding_text
    template = <<TEMPLATE
<p>Here's some code:</p>
```ruby
puts "Hello, world!"
```
<p>And that's all...</p>

TEMPLATE
    highlighting = CodeHighlighting.new(template)
    result = highlighting.substitute_code_templates
    assert_match /\r\n/, result
    assert_match /<div class="highlight">/, result
    refute_match /```/, result
  end
end
