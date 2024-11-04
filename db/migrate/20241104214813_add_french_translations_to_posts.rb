class AddFrenchTranslationsToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :title_fr, :text
    add_column :posts, :content_fr, :text
  end
end
