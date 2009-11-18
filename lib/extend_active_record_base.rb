 class ActiveRecord::Base
  def set_attrs(opt)
    raise TypeError unless opt.instance_of? Hash
    self.tap do
      opt.each do |attr_name, value|
        self.__send__(attr_name.to_s + "=", value)
      end
    end
  end
end