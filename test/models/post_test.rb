require "test_helper"

class PostTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

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

  def test_sends_emails_out_created_status_published
    post = nil
    assert_enqueued_with(job: NewPostEmailSubscribersJob) do
      post = create_post!(status: "published")
    end
    assert post.first_published_at
    assert post.first_published_now
  end

  def test_sends_emails_out_status_changed_to_published
    post = nil
    assert_no_enqueued_jobs do
      post = create_post!(status: "draft")
    end
    refute post.first_published_at
    refute post.first_published_now
    assert_enqueued_with(job: NewPostEmailSubscribersJob) do
      post.update!(status: "published")
    end
    assert post.first_published_at
    assert post.first_published_now
  end

  def test_doesnt_send_emails_out_status_changed_back_to_published
    post = nil
    assert_enqueued_with(job: NewPostEmailSubscribersJob) do
      post = create_post!(status: "published")
    end
    assert post.first_published_at
    assert post.first_published_now
    post.update!(status: "draft")
    post = Post.find(post.id)
    assert_no_enqueued_jobs do
      post.update!(status: "published")
    end
    refute post.first_published_now
  end

  def test_post_set_tag_ids
    tag1 = tags(:ruby)
    tag2 = tags(:programming)
    p = posts(:draft_no_tags)
    p.tag_ids = [tag1.id, tag2.id]
    p.save!
    p = Post.find(p.id)
    assert_equal 2, p.tags.size
    assert_equal 2, p.post_tags.size
  end

  private

  def create_post!(title: "title", content: "post content!", status: "draft")
    user = User.create!(email: "lukeg@admin.com", admin: true, password: "123123", password_confirmation: "123123")
    Post.create!(
      user: user,
      title: title,
      content: content,
      status: status,
    )
  end
end
