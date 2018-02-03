require 'yaml'
require 'json'
require 'bundler/setup'
require_relative './lib/bitflyer'
require_relative './lib/coincheck'
require 'time'

threads = []
tickers = {}

config = YAML.load_file("./etc/config.yml")

puts Time.now.to_s + " " + "--------------------ARBITRAGER--------------------"
puts Time.now.to_s + " " + "Looking for order book"
config["brokers"].each_with_index do |broker, i|
  threads << Thread.new do
    if(broker["broker"] == "bitflyer")
      bf = Bitflyer.new(broker["key"], broker["secret"])
      bid, ask = bf.read_ticker
      tickers.store(:bitflyer_bid, bid)
      tickers.store(:bitflyer_ask, ask)
      puts "bb" + Time.now.iso8601(6).to_s
    elsif(broker["broker"] == "coincheck")
      cc = Coincheck.new(broker["key"], broker["secret"])
      bid, ask = cc.read_ticker
      tickers.store(:coincheck_bid, bid)
      tickers.store(:coincheck_ask, ask)
      puts "cc" + Time.now.iso8601(6).to_s
    end
  end
end

threads.each { |th| th.join }

puts tickers
min, max = tickers.minmax { |n, m| n[1] <=> m[1] }
puts min
puts max