class Information < ActiveRecord::Base

  validates_presence_of     :title

  def self.max_photos
    3
  end

  def init_photos
    (self.class.max_photos - self.photos.size).times{self.photos.build}
    self
  end
end
