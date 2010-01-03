module MobileUtilHelper
  # guid=ONを付与する
  def url_rewrite_guid(options)
    if /\?/ =~ options
      options = insert_guid(options, "&")
    else
      options = insert_guid(options, "?")
    end
    options
  end

  def docomo?
    request.mobile? && request.mobile.docomo?
  end

  def guid_tag
    "<input type=\"hidden\" name=\"guid\" value=\"ON\" />"
  end
  
  # 自サイトのときのみguid=ONを付与するための条件
  def guid_need?(options)
    reg = "^https?://#{request.host_with_port}|^/.*"
    /#{reg}/ =~ options && /guid=ON/i !~ options
  end

  private
      def insert_guid(options, delimiter)
        if /#/ =~ options
          options.sub!(/([^#]*)(#[^#]*)/){ $1 + "#{delimiter}guid=ON" + $2 }
        else
          options += "#{delimiter}guid=ON"
        end
        options
      end
end