# redis-cache

A Ruby-on-Rails-like cache store, that stores data in Redis.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     redis-cache:
       github: your-github-user/redis-cache
   ```

2. Run `shards install`

## Usage

```crystal
require "redis-cache"
```

It's important to note that Redis cache value must be string.

### Basic example

```crystal
# configure via Habitat
RedisCache.configure do |config|
  # redis connection
  config.redis = Redis::PooledClient.new(
    host: "localhost",
    port: 6379,
    database: 0,
    pool_size: 1
  )
  # # write data to redis when fetch function called?
  config.fetch_with_cache = true
  # cache-key prefix
  config.prefix = "cache_prefix"
end

# fetch method
#
# This method does both reading and writing to the cache.
# Passed block will be executed in the event of a cache miss.
# The return value of the block will be written to the cache under the given cache key, and that return value will be returned.
# In case of cache hit, the cached value will be returned without executing the block.
# Passed block to the fetch method should return a value that can be converted to a string via `to_s` method.
# It can be JSON-string, array of numbers, etc.
# `key` argument also can be array, symbol, number, etc.
result = RedisCache.fetch(key: [:foo, :bar, :v1], ttl: 86400) do
  # ...
  # some code
  # ...

  value.to_s
end

# read method
# Searches Redis for a value by a given key.
result = RedisCache.read(key: "foo:bar")

# write method
# Writes the value for the given key to Redis.
result = RedisCache.write(key: [:foo, :bar], value: "cached value")

# delete method
# Removes the value in Redis by the given key.
RedisCache.delete(key: [:foo, :bar])
```

## Contributing

1. Fork it (<https://github.com/your-github-user/redis-cache/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [SShekotihin](https://github.com/your-github-user) - creator and maintainer
