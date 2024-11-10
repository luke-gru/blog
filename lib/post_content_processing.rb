class PostContentProcessing
  class Error < StandardError; end
  class FootnoteStrictCheckError < Error; end

  # @param String content
  def initialize(content, strict: false)
    raise ArgumentError unless content.instance_of?(String) # no AS::Safebuffers
    @content = content
    @strict = strict
  end

  # @return String, new string
  def process
    footnotes_found = {ptr: {}, exp: {}} # set of found footnotes
    scrubber = Loofah::Scrubber.new do |node|
      case node.name
      when "filename"
        process_filename_tag(node)
      when "footnote-ptr"
        process_footnote_ptr_tag(node, footnotes_found)
      when "footnote-exp"
        process_footnote_exp_tag(node, footnotes_found)
      when "text"
        process_backticks(node)
      end
    end
    result = Loofah.scrub_html4_fragment(@content, scrubber).to_s
    if @strict && (footnotes_found[:ptr].keys.sort != footnotes_found[:exp].keys.sort)
      raise FootnoteStrictCheckError, "footnote ptrs: #{footnotes_found[:ptr].keys.sort}, footnote exp: #{footnotes_found[:exp].keys.sort}"
    end
    result
  end

  private

  # <filename>helper.rb</filename> => <p class="post-filename">helper.rb</p>
  # <filename inline>helper.rb</filename> => <span class="post-filename">helper.rb</span>
  def process_filename_tag(node)
    if node.get_attribute(:inline)
      node.remove_attribute("inline")
      node.name = "span"
    else
      node.name = "p"
    end
    node.set_attribute(:class, "post-filename")
  end

  # <footnote-ptr num=1 /> => <a href="#footnote1" class="post-footnote-ptr">[1]</a>
  def process_footnote_ptr_tag(node, footnotes_found)
    num = node.get_attribute(:num).to_i
    raise "invalid <footnote-ptr>, num=#{num}" unless num > 0
    if footnotes_found[:ptr][num]
      raise "<footnote-ptr num=#{num}> is already in the post"
    end
    footnotes_found[:ptr][num] = true
    node.name = "a"
    node.remove_attribute("num")
    node.set_attribute("href", "#footnote#{num}")
    node.set_attribute("class", "post-footnote-ptr")
    node.content = "[#{num}]"
  end

  # <footnote-exp num=1>Explanation</footnote-exp> => <p class="footnote-explanation"><a target="#footnote1">[1]</a> Explanation</p>
  def process_footnote_exp_tag(node, footnotes_found)
    num = node.get_attribute(:num).to_i
    raise "invalid <footnote-exp>, num=#{num}" unless num > 0
    if footnotes_found[:exp][num]
      raise "<footnote-exp num=#{num}> is already in the post"
    end
    footnotes_found[:exp][num] = true
    node.name = "p"
    node.remove_attribute("num")
    node.set_attribute("class", "footnote-explanation")
    text = node.text
    node.content = "" # clear the text
    node.add_child(%Q(<a target="#footnote1">[#{num}]</a> #{text}))
  end

  # `hi` => <span class="post-highlight">hi</span>
  def process_backticks(node)
    res = node.text.gsub(/`(.+?)`/) do |inner|
      %Q(<span class="post-highlight">#{inner[1...-1]}</span>)
    end
    if node.text != res
      node.content = ""
      node.parent.add_child(res)
    end
  end
end
