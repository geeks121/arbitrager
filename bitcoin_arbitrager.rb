require 'yaml'
require 'json'
require 'bundler/setup'
require_relative './lib/bitflyer'
require_relative './lib/coincheck'

brokers = Array.new
tickers = Hash.new

config = YAML.load_file("./etc/config.yml")

puts Time.now.to_s + " " + "--------------------ARBITRAGER--------------------"
puts Time.now.to_s + " " + "Looking for order book"
config["brokers"].each_with_index do |broker, i|
  th = Thread.new do
    if(broker["broker"] == "bitflyer")
      brokers[i] = Bitflyer.new(broker["key"], broker["secret"])
      bid, ask = brokers[i].read_ticker
      tickers.store(:bitflyer_bid, bid)
      tickers.store(:bitflyer_ask, ask)
    elsif(broker["broker"] == "coincheck")
      brokers[i] = Coincheck.new(broker["key"], broker["secret"])
      bid, ask = brokers[i].read_ticker
      tickers.store(:coincheck_bid, bid)
      tickers.store(:coincheck_ask, ask)
    end
  end

  th.join
end

puts tickers
min, max = tickers.minmax { |n, m| n[1] <=> m[1] }
puts min
puts max