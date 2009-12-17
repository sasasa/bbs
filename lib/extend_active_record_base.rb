class ActiveRecord::Base
  #まとめてインスタンスに値を設定させる
  #attr_protectedやattr_accessibleを無視するので注意
  def set_attrs(opt)
    raise TypeError unless opt.instance_of? Hash
    self.tap do
      opt.each do |attr_name, value|
        self.__send__(attr_name.to_s + "=", value)
      end
    end
  end

  def self.right_ttl
    RAILS_ENV == "development" ? {:ttl => 30.second} : {:ttl => 30.second}
  end

  # find(id)の時のキャッシュ用
  def self.cache_find(id)
    self.get_cache("#{self}.cache_find(#{id})") do
      find(id)
    end
  end
end