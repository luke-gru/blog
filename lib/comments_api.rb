# frozen_string_literal: true
class CommentsApi
  # @param Array<PostComment> comments
  # @param Array<Integer> mine:, array of ids
  def initialize(comments, mine: [])
    @comments = comments
    @mine = mine
  end

  def as_json(options = {})
    @comments.map do |c|
      {
        id: c.encoded_id,
        comment: c.comment,
        username: c.username,
        mine: @mine.include?(c.id)
      }
    end
  end
end
