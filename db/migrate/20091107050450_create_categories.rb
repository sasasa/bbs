class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.integer :parent_id
      t.boolean :is_most_underlayer, :default=>false
      t.timestamps
    end
    add_index :categories, :parent_id
  end

  def self.down
    drop_table :categories
  end
end
