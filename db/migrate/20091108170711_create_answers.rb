class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.text :content
      t.text :supplement_comment
      t.text :thanks_comment
      t.string :url
      t.integer :kind
      t.integer :confidence
      t.integer :character
      t.boolean :receive_mail
      t.integer :user_id
      t.integer :question_id
      t.timestamps
    end
    add_index :answers, :user_id
    add_index :answers, :question_id
    add_index :answers, [:question_id, :created_at]
  end

  def self.down
    drop_table :answers
  end
end
