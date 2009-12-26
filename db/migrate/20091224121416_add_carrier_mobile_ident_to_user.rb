class AddCarrierMobileIdentToUser < ActiveRecord::Migration
  def self.up
    add_column :users,:mobile_ident,:string
    add_column :users,:carrier,:integer
  end

  def self.down
    remove_column :users,:mobile_ident
    remove_column :users,:carrier
  end
end
