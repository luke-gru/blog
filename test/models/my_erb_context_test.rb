require "test_helper"

class MyErbContextTest < ActiveSupport::TestCase

  def test_route_paths_work_in_erb
    template = erb_template("{%= posts_page_path(id: 1, locale: 'en') %}")
    context = MyErbContext.new
    result = template.evaluate(context)
    assert result.start_with?("/en/"), "#{result} should start with '/en/'"
  end

  private

  def erb_template(content)
    Erubis::Eruby.new(content, pattern: "{% %}")
  end

end
