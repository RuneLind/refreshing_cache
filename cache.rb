class Cache
  TIME_LIMIT = 1000*60
  CacheItem = Struct.new(:value, :fetch_time, :read_time)
  attr_accessor :now, :limit

  def initialize(service)
    @service = service
    @cache   = {}
    @now     = lambda { Time.now }
    @limit   = 100
  end

  def [] (key)
    if @cache[key].nil? || expired?(key)
      remove_oldest if @cache.size >= limit
      @cache[key] = CacheItem.new(@service[key], now.call())
    end
    @cache[key].read_time = now.call()
    @cache[key].value
  end

  def remove_oldest
    @cache.delete @cache.sort_by { |k, v| v.read_time }.first[0]
  end

  def expired?(key)
    now.call() > @cache[key].fetch_time + TIME_LIMIT
  end
end