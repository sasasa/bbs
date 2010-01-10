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

# 複数行で表示するようなテキストの場合のバリデーション
# 用途としては表示がずれないようにするため
def self.validates_text(*attrs)
  options = attrs.extract_options!.symbolize_keys
  #default 一行に30文字まで、行数は10行まで
  options.reverse_merge!(:max_length_per_row=>30, :max_size_row=>10)
  max_size_row = options.delete(:max_size_row)
  max_length_per_row = options.delete(:max_length_per_row)
  attrs = attrs.flatten

  validates_each attrs, options do |record, attr, val|
    # allow nilとするnilチェックはほかのバリデーションで行う
    if val
      texts_per_row = val.split(/\n/)

      max_number_row_error = texts_per_row.size > max_size_row.to_i
      max_number_per_row_error =
        texts_per_row.any? do |text|
          text.split(//u).length > max_length_per_row
        end

      if max_number_row_error || max_number_per_row_error
        error_mess = "は"
        error_mess += "行数が#{max_size_row}行までです。" if max_number_row_error
        error_mess += "一行あたり#{max_length_per_row}文字までです。" if max_number_per_row_error
        record.errors.add attr, error_mess
      end
    end
  end
end
end