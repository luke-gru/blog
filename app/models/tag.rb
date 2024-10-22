class Tag < ApplicationRecord
  validates :tag, presence: true, uniqueness: true
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "tag", "updated_at"]
  end

  # for activeadmin display purposes
  def name
    tag
  end
end
