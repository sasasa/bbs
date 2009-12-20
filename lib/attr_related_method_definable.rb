module AttrRelatedMethodDefinable
  def self.included(recipient)
    recipient.extend(ModelClassMethods)
    recipient.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    # 引数 :attr1=>val1, :attr2=>val2
    # 以下のメソッドを定義する
    # 
    # デフォルト値を返す
    # def attr1_default_val
    #   val1
    # end
    # デフォルト値を設定する
    # def set_default_val
    #   self.attr1 = attr1_default_val
    #   self.attr2 = attr2_default_val
    #   self
    # end
    def attr_default_val(opt)
      define_attr_related_method("_default_val", opt)
#      text =
#        opt.inject("") do |memo, pair|
#          memo << "self.#{pair.first.to_s} = #{pair.first.to_s}_default_val;"
#        end
      text =
        "".tap do |s|
          opt.each do |atrr_name, val|
            s << "self.#{atrr_name.to_s} = #{atrr_name.to_s}_default_val;"
          end
        end
      define_method("set_default_val") do
        self.tap do
          eval(text)
        end
      end
    end
    # 引数 :attr1=>val1, :attr2=>val2
    # 以下のメソッドを定義する
    # マスタを返す
    # def attr1_mst
    #   val1
    # end
    def attr_mst(opt)
      define_attr_related_method("_mst", opt)
    end
    # 引数 :attr1=>val1, :attr2=>val2
    # val1は以下のような形式である必要がある {attr1の値=>"文字列1",attr1の値=>"文字列2"}
    # 以下のメソッドを定義する
    # 属性に基付く文字列表現を返す
    # def attr1_text
    #   val1[attr1]
    # end
    def attr_text(opt)
      raise TypeError unless opt.instance_of? Hash
      opt.each do |attr_name, val|
        raise TypeError unless val.instance_of? Hash
        define_method(attr_name.to_s + "_text") do
          val[eval(attr_name.to_s)]
        end
      end
    end

    def define_attr_related_method(suffix, opt)
      raise TypeError unless opt.instance_of? Hash
      opt.each do |attr_name, val|
       define_method(attr_name.to_s + suffix) do
          val
        end
      end
    end
  end

  module ModelInstanceMethods
  end # instance methods
end
