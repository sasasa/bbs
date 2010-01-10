class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :zip_code
      t.string :prefecture
      t.string :district
      t.string :town, :limit=>2048
      t.string :kana_prefecture
      t.string :kana_district
      t.string :kana_town, :limit=>2048
      t.boolean :is_merge

      t.timestamps
    end
    add_index :addresses, :zip_code
    add_index :addresses, :prefecture
    add_index :addresses, :district
    add_index :addresses, :town
    add_index :addresses, :kana_prefecture
    add_index :addresses, :kana_district
    add_index :addresses, :kana_town
  end

  def self.down
    drop_table :addresses
  end
end
