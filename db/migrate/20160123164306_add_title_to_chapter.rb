class AddTitleToChapter < ActiveRecord::Migration
  def change
    add_column :chapters, :title, :string, after: :tale_id
  end
end
