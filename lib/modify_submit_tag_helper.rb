# submit_tag にデフォルトのclass属性を付加する
# 初期化時に読み込ませる
module ActionView
  module Helpers
    module FormTagHelper
      def submit_tag_with_class_attr(value = "Save changes", options = {})
        options.reverse_merge!(:class=>"submit")
        submit_tag_without_class_attr(value, options)
      end
      alias_method_chain :submit_tag, :class_attr  #:nodoc:
    end
  end
 end