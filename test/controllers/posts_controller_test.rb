require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index success" do
    get posts_page_url(locale: I18n.locale)
    assert_response :success
  end

  test "should get post page success" do
    post = posts(:first_published)
    get post_page_url(locale: I18n.locale.to_s, id: post.id)
    assert_response :success
  end
end
