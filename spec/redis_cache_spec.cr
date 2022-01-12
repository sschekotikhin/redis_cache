require "./spec_helper"

describe RedisCache do
  it "with custom settings" do
    client = Redis::PooledClient.new(
      host: ENV["REDIS_HOST"]? || "localhost",
      port: ENV["REDIS_PORT"]? ? ENV["REDIS_PORT"].to_i : 6379,
      database: 0,
      pool_size: 10
    )

    RedisCache.configure do |config|
      config.redis = client
      config.fetch_with_cache = true
      config.prefix = "redis_cache"
    end

    RedisCache.settings.redis.should eq client
    RedisCache.settings.fetch_with_cache.should eq true
    RedisCache.settings.prefix.should eq "redis_cache"
  end

  describe "methods" do
    before_each do
      redis = Redis.new(
        host: ENV["REDIS_HOST"]? || "localhost",
        port: ENV["REDIS_PORT"]? ? ENV["REDIS_PORT"].to_i : 6379,
        database: 0
      )

      RedisCache.configure do |config|
        config.redis = redis
        config.fetch_with_cache = true
      end

      redis.flushdb
    end

    describe "#fetch" do
      it "writes and returns data" do
        result = RedisCache.fetch(key: "writes and returns data") do
          [1, 2, 3, 4, 5].to_s
        end

        RedisCache.read("writes and returns data").should eq result
      end

      it "key have ttl" do
        RedisCache.fetch(key: "key have ttl", ttl: 10) { "expirable value" }

        Redis.new(
          host: ENV["REDIS_HOST"]? || "localhost",
          port: ENV["REDIS_PORT"]? ? ENV["REDIS_PORT"].to_i : 6379,
          database: 0
        ).ttl("#{RedisCache.settings.prefix}:key have ttl").should eq 10
      end

      it "does not write to Redis if fetch_with_cache = false" do
        RedisCache.settings.fetch_with_cache = false
        RedisCache.fetch(key: "does not write to Redis if fetch_with_cache = false") { "some value" }

        RedisCache.read(key: "does not write to Redis if fetch_with_cache = false").should eq nil
      end

      it "works with different types of key" do
        RedisCache.fetch(key: [1, 2, 3, "foo", :bar]) {}
        RedisCache.fetch(key: "string key") {}
        RedisCache.fetch(key: :symbol_key) {}
      end
    end

    describe "#write" do
      it "key have ttl" do
        RedisCache.write(key: "key have ttl", ttl: 10, value: "expirable value")

        Redis.new(
          host: ENV["REDIS_HOST"]? || "localhost",
          port: ENV["REDIS_PORT"]? ? ENV["REDIS_PORT"].to_i : 6379,
          database: 0
        ).ttl("#{RedisCache.settings.prefix}:key have ttl").should eq 10
      end

      it "writes and returns data" do
        value = [1, 2, 3, 4, 5].to_s
        RedisCache.write(key: "writes and returns data", value: value)

        RedisCache.read("writes and returns data").should eq value
      end

      it "writes data if fetch_with_cache = false" do
        RedisCache.settings.fetch_with_cache = false
        RedisCache.write(key: "writes data if fetch_with_cache = false", value: 1)

        RedisCache.read(key: "writes data if fetch_with_cache = false").should eq "1"
      end
    end
  end
end
