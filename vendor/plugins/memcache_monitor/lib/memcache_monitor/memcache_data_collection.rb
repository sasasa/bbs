module MemcacheMonitor
  class MemcacheDataCollection
    def initialize
      @@memcache ||= ActsAsCached::Config.setup_memcache(ActsAsCached.config) #ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS['cache']
      @dump_data_every_server = @@memcache.dump_data_all_server
      @dump_data_every_server || {}
    end
    cattr_reader :memcache
    attr_reader :dump_data_every_server
  end
end