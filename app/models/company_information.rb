class CompanyInformation < ActiveRecord::Base
  has_many :photos, :dependent => :destroy,
    :class_name=>Photo.has_attachment(:content_type => :image,
                                :min_size => 1.byte,
                                :max_size => 10.megabyte,
                                :storage => :file_system, #:db_file,
                                :resize_to => '340x200>',#widthxheigtの制限
                                :thumbnails => { :thumb => '100x100>', :small => '60x60>' })

  accepts_nested_attributes_for :photos, :allow_destroy => true

  validates_presence_of     :title

  def self.max_photos
    3
  end

  def init_photos
    (self.class.max_photos - self.photos.size).times{self.photos.build}
    self
  end
end
