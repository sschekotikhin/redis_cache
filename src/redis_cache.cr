require "habitat"
require "redis"

# :nodoc:
module RedisCache
  VERSION = "0.1.0"

  Habitat.create do
    # redis connection
    setting redis : Redis | Redis::PooledClient
    # cache-key prefix
    setting prefix : String = "cache"
    # write data to redis when fetch function called?
    setting fetch_with_cache : Bool = false
  end

  {% for key_type in [Symbol, String, Array(String | Int64 | Symbol)] %}
    # Searches for a value in Redis and, if it exists, returns it;
    # if not, it executes the passed block, and writes the resulting value to Redis.
    #
    # Returns the value written to the base.
    def self.fetch(
      key : {{key_type.id}},
      ttl : Int64 | Nil = nil,
      &block : -> String | Int64 | Float64 | Nil
    ) : String | Int64 | Float64 | Nil
      cached_value = if settings.fetch_with_cache && (val = read(key)) # already exists
        val
      else # not found :(
        val = yield
        write(key, val.to_s, ttl) if settings.fetch_with_cache

        val
      end

      cached_value
    end

    # Searches Redis for a value by a given key.
    #
    # Returns the value found in the database.
    def self.read(key : {{key_type.id}}) : String | Int64 | Float64 | Nil
      settings.redis.get(stringify_key(key))
    end

    # Writes the value for the given key to Redis.
    #
    # Returns the value written to Redis.
    def self.write(
      key : {{key_type.id}},
      value : String | Int64 | Float64,
      ttl : Int64 | Nil
    ) : String | Int64 | Float64 | Nil
      settings.redis.set(
        stringify_key(key),
        value,
        ttl
      )
    end

    # Removes the value in Redis by the given key.
    #
    # Returns a boolean value - has the entry been deleted?
    def self.delete(key : {{key_type.id}}) : Bool
      settings.redis.del(stringify_key(key)).positive?
    end

    # Forms the string value of the key.
    #
    # Returns the string representation of the key.
    private def self.stringify_key(key : {{key_type.id}}) : String
      cache_key = [settings.prefix]
      cache_key << if [Symbol, String].includes?(typeof(key))
        key.to_s
      else
        key.join(":").to_s
      end

      cache_key.join(":")
    end
  {% end %}
end
