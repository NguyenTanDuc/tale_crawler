class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.references :tale, index: true
      t.integer :chapter
      t.text :content_text, limit: 16777215
      t.text :content_html, limit: 16777215
      t.string :link, limit: 1024
      t.integer :display_type

      t.timestamps
    end
  end
end
