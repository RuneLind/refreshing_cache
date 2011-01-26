require "rspec"
require_relative '../cache'

describe Cache do
  let(:service) { mock.as_null_object }
  let(:cache) { Cache.new(service) }

  it "should read missing values from service" do
    service.stub(:[]).with("third").and_return 3
    cache["third"].should == 3
  end

  it "should read missing values from service only one" do
    service.should_receive(:[]).once.with("third")
    cache["third"]
    cache["third"]
  end

  it "should discard items older than limit" do
    cache.now = lambda { Time.now }

    cache["third"]
    cache.now = lambda { Time.now + Cache::TIME_LIMIT + 1 }

    service.should_receive(:[]).once.with("third")
    cache["third"]
  end

  it "should discard oldest item when cache is full" do
    # arrange
    cache.limit = 2
    %w(first second third).each { |key| cache[key] }

    # assert
    service.should_receive(:[]).once.with('first')

    # act
    cache['first']
  end

  it "should discard least recently used item when cache is full" do
    # arrange
    cache.limit = 2
    %w(first second first third).each { |key| cache[key] }

    # assert
    service.should_receive(:[]).never.with("first")

    # act
    cache['first']
  end
end