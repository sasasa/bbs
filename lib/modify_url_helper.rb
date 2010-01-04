# リンクやformの生成をdocomoからのアクセスに最適化する
# 初期化時に読み込ませる

module ActionView
  module Helpers
    module FormTagHelper
      private
        # formタグを作成する際にdocomoならguidをつける。
        def extra_tags_for_form_with_guid(html_options)
          buf = extra_tags_for_form_without_guid(html_options)
          if docomo? && buf.blank?
            buf = content_tag(:div, guid_tag, :style => 'margin:0;padding:0;display:inline')
          elsif docomo?
            buf.sub!(/<\/div>$/, "#{guid_tag}<\/div>")
          end
          buf
        end
        alias_method_chain :extra_tags_for_form, :guid
        
        # ひとまずUTNは使わないことに変更
        # formタグを作成する際にSSLでdocomoならutnをつける。
#        def form_tag_html_with_utn(html_options)
#          html_options.merge!(:utn=>"utn") if docomo? && request.ssl?
#          form_tag_html_without_utn(html_options)
#        end
#        alias_method_chain :form_tag_html, :utn
    end
  end
end

module ActionController
  class Base
    include MobileUtilHelper
    protected
      # 自サイトにリダイレクトする際にdocomoならguidをつける
      def redirect_to_full_url_with_guid(url, status)
        if docomo? && guid_need?(url)
          url = url_rewrite_guid(url)
        end
        redirect_to_full_url_without_guid(url, status)
      end
      alias_method_chain :redirect_to_full_url, :guid
  end
end

module ActionView
  module Helpers #:nodoc:
    module UrlHelper
      # ひとまずUTNは使わないことに変更
      # docomoで自サイトへのhttpsへのリンクかhttpsのページ内でのリンクのときはutnをつける
#      def link_to_with_utn(*args, &block)
#        if !block_given? && docomo? && (/#{"^https://#{request.host_with_port}"}/ =~ args.second || (request.ssl? && /#{"^http://#{request.host_with_port}"}/ !~ args.second))
#          (args.third || args[2]={})[:utn] = "utn"
#        end
#        link_to_without_utn(*args, &block)
#      end
#      alias_method_chain :link_to, :utn

      # 自サイト宛のurlを作成する際にdocomoならguidをつける
      def url_for_with_guid_on(options = {})      
        if docomo?
          case options
          when String
            options = url_rewrite_guid(options) if guid_need?(options)
          when Hash
            options.merge!(:guid=>"ON")
          end
        end
        url_for_without_guid_on(options)
      end
      alias_method_chain :url_for, :guid_on
    end
  end
end
