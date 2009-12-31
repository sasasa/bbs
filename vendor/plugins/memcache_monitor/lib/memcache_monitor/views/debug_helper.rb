module MemcacheMonitor
  module Views
    module DebugHelper

      def debug_mobile_display
        <<-EOF
        color?=>#{request.mobile.display.color?}
        colors=>#{request.mobile.display.colors}
        width=>#{request.mobile.display.width}
          browser_width=>#{request.mobile.display.browser_width}
          physical_width=>#{request.mobile.display.physical_width}
        height=>#{request.mobile.display.height}
          browser_height=>#{request.mobile.display.browser_height}
          physical_height=>#{request.mobile.display.physical_height}"
        EOF
      end

      def inspect_new_line(obj)
        obj.inspect.gsub(/(.*?"),/){ $1 + ",\n"}
      end
      
      def debug_request_headers
        inspect_new_line(Hash[*request.env.select{|key,val| /rack/ !~ key && val.instance_of?(String) }.flatten] )
      end

      def debug_request
        clean_params = request.parameters.clone
        clean_params.delete("action")
        clean_params.delete("controller")
        clean_params.empty? ? 'None' : indication_lined_up_hash(clean_params.inspect.gsub(',', ",\n"))
      end

      def indication_lined_up_hash(txt)
        txt.gsub(/\A\{(.*)\}\z/){ $1 }.gsub(/(\{[^\{\}]+?\})/){ $1.gsub("\n", "") }
      end

      def debug_response
        response ? inspect_new_line(response.headers) : 'None'
      end

      def debug_session_id
        (request.session_options || ActionController::Base.session_options)[:id]
      end

      def debug_session_key
        (request.session_options || ActionController::Base.session_options)[:key]
      end

      def debug_session
        indication_session(request.session.inspect)
      end

      def indication_session(txt)
        indication_lined_up_hash(txt.gsub(/([^,]+?=>[^,]+?, )[^@{]/){ $1 + "\n" }.
                                     gsub(/([>}\]], )[^@]/){ $1 + "\n" })
      end

      def debug_active_record_store
        return nil unless (ActiveRecord::SessionStore::Session && session_rows = ActiveRecord::SessionStore::Session.find(:all))
        "".tap do |txt|
          session_rows.each do |row|
            if /#{debug_session_id}/ =~ row.session_id
              txt << ">>#{row.session_id}=>\n#{indication_session(row.data.inspect)}\n\n"
            else
              txt << "--#{row.session_id}=>\n#{indication_session(row.data.inspect)}\n\n"
            end
          end
        end
      end

      def debug_memcache(hash)
        array = hash.sort
        text = ""
        array.each do |key, val|
          text << key + "=>" + val + ",\n"
        end
        new_hash = {}
        text.each do |row|
          if row =~ /[^:]+?:([^:]+?):(.*)/
            row.gsub(/[^:]+?:([^:]+?):(.*)/){ (new_hash[$1]||=[]) << $2 }
          else
            row.gsub(/([^:]+?):(.*)/){ (new_hash[$1]||=[]) << $2 }
          end
        end
        "".tap do |ret_txt|
          new_hash.each do |key, txt_array|
            display_proc =
              lambda do |row|
                if /#{debug_session_id}/ =~ row
                  ">>#{row}\n"
                else
                  "  #{row}\n"
                end
              end
            ret_txt << "#{key}=>\n#{txt_array.map!(&display_proc)}\n"
          end
        end
      end
    end
  end
end

