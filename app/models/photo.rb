class Photo < ActiveRecord::Base
  # 各関連の親クラスからオプションを設定する※オプションはここに書いても適用されない、マージもされない、親クラスで設定した値のみ有効
  has_attachment :content_type => :image,
                  :min_size => 1.byte,
                  :max_size => 10.megabyte,
                  :storage => :file_system, #:db_file,
                  :resize_to => '340x200>',#widthxheigtの制限
                  :thumbnails => { :thumb => '100x100>', :small => '60x60>' }
  
  validates_as_attachment

  belongs_to :company_information
end
