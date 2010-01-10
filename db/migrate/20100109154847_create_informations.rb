class CreateInformations < ActiveRecord::Migration
  def self.up
    create_table :informations do |t|
      t.string :title
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :informations
  end
end
