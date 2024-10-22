class PostTag < ApplicationRecord
  belongs_to :post
  belongs_to :tag

  validates :post_id, presence: true
  validates :tag_id, presence: true


  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "post_id", "tag_id", "updated_at"]
  end
end
