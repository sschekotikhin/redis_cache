require "./spec_helper"

describe RedisCache do
  it "with custom settings" do
    client = Redis::PooledClient.new(
      host: "localhost",
      port: 6379,
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

  describe "#fetch" do
    # TODO: write specs
  end

  describe "#read" do
    # TODO: write specs
  end

  describe "#write" do
    # TODO: write specs
  end
end
