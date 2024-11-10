require "test_helper"

class PostContentProcessingTest < ActiveSupport::TestCase
  FILENAME_CLASS = "post-filename"

  def test_process_filename_tag
    src = <<SRC.rstrip
Here's a file: <filename>test.rb</filename>
SRC
    result = process(src)
    assert_equal %Q(Here's a file: <p class="#{FILENAME_CLASS}">test.rb</p>), result
  end

  def test_process_filename_inline_tag
    src = <<SRC.rstrip
Here's a file: <filename inline>test.rb</filename>
SRC
    result = process(src)
    assert_equal %Q(Here's a file: <span class="#{FILENAME_CLASS}">test.rb</span>), result
  end

  def test_process_footnote_ref
    src = <<SRC.rstrip
But there is more to it than that <footnote-ref num=1 />.
SRC
    result = process(src)
    assert_equal %Q(But there is more to it than that <a href="#footnote1" class="post-footnote-ref">[1]</a>.), result
  end

  def test_process_footnote_note
    src = <<SRC.rstrip
<footnote-note num=1>See my paper for more details</footnote-note>
SRC
    result = process(src)
    assert_equal %Q(<p class="post-footnote-note"><a target="#footnote1">[1]</a> See my paper for more details</p>), result
  end

  def test_process_multiple_footnotes
    src = <<SRC.rstrip
<footnote-ref num=1 />
<footnote-ref num=2 />
<footnote-note num=1>Hi</footnote-note>
<footnote-note num=2>Hey</footnote-note>
SRC
    result = process(src, strict: true)
    assert_equal 2, result.scan(/<a href/).size
    assert_equal 2, result.scan(/<p class="post-footnote-note"/).size
    assert_equal 0, result.scan(/<footnote/).size
  end

  def test_process_footnote_strict_checking_number_mismatch
    src = <<SRC.rstrip
<footnote-ref num=1 />
<footnote-ref num=2 />
<footnote-note num=2>Hi</footnote-note>
<footnote-note num=3>Hey</footnote-note>
SRC
    assert_raise PostContentProcessing::FootnoteStrictCheckError do
      process(src, strict: true)
    end
  end

  def test_process_backticks
    src = <<SRC.rstrip
<p>Make sure to update the `class` and `def` keywords.</p>
SRC
    result = process(src)
    assert_equal %Q(<p>Make sure to update the <span class="post-highlight">class</span> and <span class="post-highlight">def</span> keywords.</p>), result
  end

  private

  # @return String
  def process(src, strict: false)
    PostContentProcessing.new(src, strict: strict).process
  end

end
