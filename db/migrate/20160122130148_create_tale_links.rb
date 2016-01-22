class CreateTaleLinks < ActiveRecord::Migration
  def change
    create_table :tale_links do |t|
      t.string :tale_link

      t.timestamps
    end
  end
end
