class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.references :tale, index: true
      t.integer :chapter
      t.text :content_text
      t.text :content_html
      t.string :link

      t.timestamps
    end
  end
end
