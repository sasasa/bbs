class CompanyInformation < Information
  has_many :photos, :dependent => :destroy, :foreign_key=>'information_id',
    :class_name=>Photo.has_attachment(:content_type => :image,
                                :min_size => 1.byte,
                                :max_size => 10.megabyte,
                                :storage => :file_system, #:db_file,
                                :resize_to => '340x200>',#widthxheigtの制限
                                :thumbnails => { :thumb => '100x100>', :small => '60x60>' })
  accepts_nested_attributes_for :photos, :allow_destroy => true
end
