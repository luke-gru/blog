require "test_helper"

class PostCommentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index success (no comments)" do
    post = posts(:first_published)
    post.create_or_update_slug!
    get post_comments_path(post, locale: I18n.locale), as: :json
    assert_response :success
    assert_equal({comments: []}.to_json, @response.body)
  end

  test "should get index success (1 whitelisted comment)" do
    post = posts(:first_with_comments)
    post.create_or_update_slug!
    get post_comments_path(post, locale: I18n.locale), as: :json
    assert_response :success
    res = json_response
    assert_equal 1, res["comments"].size
  end

  test "should render error when no post found" do
    get post_comments_path(post_id: "invalid-post", locale: I18n.locale), as: :json
    assert_response :unprocessable_entity
    res = json_response
    assert_equal false, res["success"]
    assert_equal true,  res["post_not_found"]
  end

  test "should create comment (success)" do
    post = posts(:first_published)
    post.create_or_update_slug!
    post post_comments_create_path(post,
      locale: I18n.locale,
      params: { comment: "Hello!", username: "user" },
      as: :json
    )
    assert_response :success
  end

  test "should not create comment (error)" do
    post = posts(:first_published)
    post.create_or_update_slug!
    post post_comments_create_path(post,
      locale: I18n.locale,
      params: { comment: "", username: "" },
      as: :json
    )
    assert_response :unprocessable_entity
  end

  test "can update one's own comment" do
    post = posts(:first_with_comments)
    comment = post.comments.whitelisted.last
    assert comment.present?
    comment_id = PostComment.encode_id(comment.id)
    set_signed_cookie(:comments_created, [comment_id])
    patch post_comments_update_path(
      locale: I18n.locale,
      comment_id: comment_id,
      params: { comment: "updated comment" },
      as: :json
    )
    assert_response :success
    assert_equal "updated comment", comment.reload.comment
  end

  test "can not update anyone else's comment (wrong cookie value)" do
    post = posts(:first_with_comments)
    comment = post.comments.whitelisted.last
    assert comment.present?
    comment_id = PostComment.encode_id(comment.id + 1)
    set_signed_cookie(:comments_created, [comment_id])
    patch post_comments_update_path(
      locale: I18n.locale,
      comment_id: comment_id,
      params: { comment: "updated comment" },
      as: :json
    )
    assert_response :unprocessable_entity
  end

  test "can not update anyone else's comment (no cookie value, raw comment id)" do
    post = posts(:first_with_comments)
    comment = post.comments.whitelisted.last
    assert comment.present?
    comment_id = comment.id
    patch post_comments_update_path(
      locale: I18n.locale,
      comment_id: comment_id,
      params: { comment: "updated comment" },
      as: :json
    )
    assert_response :unprocessable_entity
  end

  test "can not update anyone else's comment (no cookie value, encoded comment id)" do
    post = posts(:first_with_comments)
    comment = post.comments.whitelisted.last
    assert comment.present?
    comment_id = PostComment.encode_id(comment.id)
    patch post_comments_update_path(
      locale: I18n.locale,
      comment_id: comment_id,
      params: { comment: "updated comment" },
      as: :json
    )
    assert_response :unprocessable_entity
  end

  test "can delete one's own comment" do
    post = posts(:first_with_comments)
    comment = post.comments.whitelisted.last
    assert comment.present?
    comment_id = PostComment.encode_id(comment.id)
    set_signed_cookie(:comments_created, [comment_id])
    delete post_comments_delete_path(
      locale: I18n.locale,
      comment_id: comment_id,
      as: :json
    )
    assert_response :success
    assert_nil PostComment.find_by_id(comment.id)
  end

  private

  def json_response
    JSON.parse(@response.body)
  end

  def set_signed_cookie(key, val)
    @_my_cookies ||= ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
    @_my_cookies.signed[key] = val
    cookies[key] = @_my_cookies[key]
  end
end
