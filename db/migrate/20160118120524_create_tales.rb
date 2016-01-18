class CreateTales < ActiveRecord::Migration
  def change
    create_table :tales do |t|
      t.string :name
      t.string :author
      t.references :category, index: true
      t.string :source
      t.string :link
      t.boolean :status
      t.integer :chapter_number
      t.integer :last_chapter

      t.timestamps
    end
  end
end
