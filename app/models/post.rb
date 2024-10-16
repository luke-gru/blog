class Post < ApplicationRecord
  belongs_to :user
  has_rich_text :content
  validates :user, presence: true
  validates :title, presence: true
  validates :content, presence: true
  def self.ransackable_associations(auth_object = nil)
    ["rich_text_content", "user"]
  end

  def self.ransackable_attributes(*)
    ["content", "created_at", "id", "id_value", "title", "updated_at", "user_id"]
  end
end
