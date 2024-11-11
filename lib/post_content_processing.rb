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
    footnotes_found = {ref: {}, note: {}} # set of found footnotes
    scrubber = Loofah::Scrubber.new do |node|
      case node.name
      when "filename"
        process_filename_tag(node)
      when "footnote-ref"
        process_footnote_ref_tag(node, footnotes_found)
      when "footnote-note"
        process_footnote_note_tag(node, footnotes_found)
      when "text"
        if node.parent && node.parent.name == "p"
          process_backticks(node)
        end
      end
    end
    result = Loofah.scrub_html4_fragment(@content, scrubber).to_s
    if @strict && (footnotes_found[:ref].keys.sort != footnotes_found[:note].keys.sort)
      raise FootnoteStrictCheckError, "footnote refs: #{footnotes_found[:ref].keys.sort}, footnote note: #{footnotes_found[:note].keys.sort}"
    end
    result
  end

  private

  # <filename>helper.rb</filename> => <p class="post-filename"><span>helper.rb</span></p>
  # <filename inline>helper.rb</filename> => <span class="post-filename">helper.rb</span>
  def process_filename_tag(node)
    if inline = node.get_attribute(:inline)
      node.remove_attribute("inline")
      node.name = "span"
    else
      node.name = "p"
    end
    node.set_attribute(:class, "post-filename")
    unless inline
      filename = node.text
      node.content = ""
      node.add_child(Nokogiri::XML.fragment("<span>#{filename}</span>"))
    end
  end

  # <footnote-ref num=1 /> => <a href="#footnote1" class="post-footnote-ref">[1]</a>
  def process_footnote_ref_tag(node, footnotes_found)
    num = node.get_attribute(:num).to_i
    raise "invalid <footnote-ref>, num=#{num}" unless num > 0
    if @strict && footnotes_found[:ref][num]
      raise FootnoteStrictCheckError, "<footnote-ref num=#{num}> is already in the post"
    end
    footnotes_found[:ref][num] = true
    node.name = "a"
    node.remove_attribute("num")
    node.set_attribute("href", "#footnote#{num}")
    node.set_attribute("class", "post-footnote-ref")
    node.content = "[#{num}]"
  end

  # <footnote-note num=1>Explanation</footnote-note> => <p class="post-footnote-note"><a target="#footnote1">[1]</a> Explanation</p>
  def process_footnote_note_tag(node, footnotes_found)
    num = node.get_attribute(:num).to_i
    raise "invalid <footnote-note>, num=#{num}" unless num > 0
    if @strict && footnotes_found[:note][num]
      raise FootnoteStrictCheckError, "<footnote-note num=#{num}> is already in the post"
    end
    footnotes_found[:note][num] = true
    node.name = "p"
    node.remove_attribute("num")
    node.set_attribute("class", "post-footnote-note")
    text = node.text
    node.content = "" # clear the text
    node.add_child(%Q(<span id="footnote1">[#{num}]</span> #{text}))
  end

  # `hi` => <span class="post-highlight">hi</span>
  def process_backticks(node)
    res = node.text.gsub(/`(.+?)`/) do |inner|
      %Q(<code class="post-highlight">#{inner[1...-1]}</code>)
    end
    if node.text != res
      new_nodes = Nokogiri::XML::fragment(res)
      node.replace(new_nodes)
    end
  end

end
