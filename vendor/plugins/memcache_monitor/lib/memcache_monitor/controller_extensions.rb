require File.join(File.dirname(__FILE__), "views", "debug_helper")

module MemcacheMonitor
  module ControllerExtensions
    class MemcacheMonitorViewBase < ActionView::Base
      include MemcacheMonitor::Views::DebugHelper
    end

    def self.included(base)
      base.alias_method_chain :perform_action, :memcache_monitor
      base.alias_method_chain :process, :memcache_monitor
      base.helper_method :memcache_monitor_output
    end

    def memcache_monitor_output(ajax)
      faux_view = MemcacheMonitorViewBase.new([File.join(File.dirname(__FILE__), "views")], {}, self)
      memcache_monitor = Thread.current["memcache_monitor"]
      faux_view.instance_variable_set("@memcache_monitor", memcache_monitor)
      if ajax
        js = faux_view.render(:partial => "/box_ajax.js")
      else
        html = faux_view.render(:partial => "/box")
      end
    end

    def add_memcache_monitor_output_to_view
      if is_ajax = request.xhr?
        #TODO?
      else
        if response.body.is_a?(String) && response.body.match(/<\/body>/i) && Thread.current["memcache_monitor"]
          idx = (response.body =~ /<\/body>/i)
          html = memcache_monitor_output(is_ajax)
          response.body.insert(idx, html)
        end
      end
    end

    def perform_action_with_memcache_monitor
      r = perform_action_without_memcache_monitor
      add_memcache_monitor_output_to_view
      r
    end

    def process_with_memcache_monitor(request, response, method = :perform_action, *arguments) #:nodoc:
      Thread.current["memcache_monitor"] = MemcacheDataCollection.new#
      process_without_memcache_monitor(request, response, method, *arguments)
    end
  end
end
