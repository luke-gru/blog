require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index success" do
    get posts_page_url(locale: I18n.locale)
    assert_response :success
  end

  test "should get redirect when no locale given to root path" do
    get "/"
    assert_redirected_to root_path(locale: "en")
  end

  test "should get success on post_page when post is published (slug=id)" do
    post = posts(:first_published)
    get post_page_url(locale: I18n.locale, id: post.id)
    assert_response :success
  end

  test "should get success on post_page when post is published (slug=title)" do
    post = posts(:first_published)
    post.create_or_update_slug!
    refute_equal post.to_param, post.id.to_s
    get post_page_url(post, locale: I18n.locale)
    assert_response :success
  end

  test "should redirect on post_page when post is a draft (slug=id)" do
    post = posts(:draft_no_tags)
    get post_page_url(locale: I18n.locale, id: post.id)
    assert_response :redirect
  end

  test "should redirect on post_page when no post (slug=id)" do
    post_id = Post.last.id + 1
    get post_page_url(locale: I18n.locale, id: post_id)
    assert_response :redirect
  end
end
