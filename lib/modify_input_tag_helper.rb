# text_field / password_field / text_area にデフォルトのclass属性を付加する
# 初期化時に読み込ませる
module ActionView
  module Helpers
    module FormHelper
      %W[text_field password_field text_area].each do |method|
        class_eval <<-"EOF"
          def #{method}_with_solid(object_name, method, options = {})
            options.reverse_merge!(:class=>'solid')
            #{method}_without_solid(object_name, method, options)
          end
          alias_method_chain :#{method}, :solid
        EOF
      end
    end
  end
end