# memcache-clientにメソッドを追加
MemCache.class_eval do
  def dump_data_all_server
    raise MemCache::MemCacheError, "No servers" unless active?
    dump_data_every_server = {}

    @servers.each do |serv|
      soc = serv.socket
      raise MemCache::MemCacheError, "No soc" if soc.nil?

      begin
        soc.write "stats items\r\n"
        items = {}
        dump_data = {}
        while line = soc.gets do
          break if line == "END\r\n"
          if line =~ /^STAT items:(\d+):number ([\w\.\:]+)/ then
            items[$1] = $2.chomp
          end
        end
        items.each do |k,v|
          soc.write "stats cachedump #{k} #{v}\r\n"
          while line = soc.gets do
            break if line == "END\r\n"
            if line =~ /^ITEM ([\w:()_.#-]+) (.+)/ then
              dump_data[$1] = $2.chomp
            end
          end
        end
        dump_data_every_server["#{serv.host}:#{serv.port}"] = dump_data
      rescue SocketError, SystemCallError, IOError => err
        serv.close
        raise MemCache::MemCacheError, err.message
      end
    end
    dump_data_every_server
  end
end