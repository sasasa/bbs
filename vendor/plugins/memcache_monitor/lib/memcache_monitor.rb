if RAILS_ENV == "development"
  require "memcache_monitor/controller_extensions"
  require "memcache_monitor/memcache_data_collection"
  ActionController::Base.send(:include, MemcacheMonitor::ControllerExtensions)

  if ActionController::Base.respond_to?(:append_view_path)
    ActionController::Base.append_view_path(File.dirname(__FILE__) + "/lib/memcache_monitor/views")
  end
end
