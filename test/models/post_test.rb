require "test_helper"

class PostTest < ActiveSupport::TestCase

  def setup
    super
  end

  def test_erb_content
    content = <<TMPL
<p>{%= "Hi" %}</p>
TMPL
    p = Post.new(content: content)
    assert_equal "<p>Hi</p>\n", p.erb_content
  end

  def test_indented_content
    content = %Q(<div><img src="/my/image.png" /></div>)
    p = Post.new(content: content)
    assert_equal %Q(<div>\n  <img src="/my/image.png"/>\n</div>\n), p.indented_content
  end
end
