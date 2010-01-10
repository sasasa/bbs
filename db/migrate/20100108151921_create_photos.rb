class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.integer :size
      t.string :content_type
      t.string :filename
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string :thumbnail
      
      t.integer :company_information_id
      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
