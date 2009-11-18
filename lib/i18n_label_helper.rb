# label :method
# と呼び出すと翻訳したラベルを返す
# 初期化時に読み込ませる
module ActionView
  module Helpers
    module FormHelper
      def label_with_ja(object_name, method, text = nil, options = {})
        if text.nil?
          text = I18n.t(method, :default => method, :scope => [:activerecord, :attributes, object_name])
        end
        label_without_ja(object_name, method, text, options)
      end
      alias_method_chain :label, :ja  #:nodoc:
    end
  end
end