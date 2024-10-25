require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index success" do
    get posts_page_url(locale: I18n.locale)
    assert_response :success
  end

  test "should get success on post_page when post is published" do
    post = posts(:first_published)
    get post_page_url(locale: I18n.locale, id: post.id)
    assert_response :success
  end

  test "should redirect on post_page when post is a draft" do
    post = posts(:draft_no_tags)
    get post_page_url(locale: I18n.locale, id: post.id)
    assert_response :redirect
  end

  test "should redirect on post_page when no post" do
    post_id = Post.last.id + 1
    get post_page_url(locale: I18n.locale, id: post_id)
    assert_response :redirect
  end
end
