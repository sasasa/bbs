class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.string :title
      t.text :content
      t.integer :state
      t.boolean :is_closed, :default=>false
      t.boolean :receive_mail, :default=>true
      t.integer :user_id
      t.integer :category_id
      t.timestamps
    end
    add_index :questions, :user_id
    add_index :questions, :category_id
    add_index :questions, [:category_id, :created_at]
  end

  def self.down
    drop_table :questions
  end
end
