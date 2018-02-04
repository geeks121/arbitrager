require 'bigdecimal'
require 'yaml'
require 'json'
require 'bundler/setup'
require_relative './lib/bitflyer'
require_relative './lib/coincheck'
require 'time'

best_bid_broker, best_ask_broker = nil
best_bid_price, best_ask_price = nil
best_bid_size, best_ask_size = nil
threads = []
boards = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
config = YAML.load_file("./etc/config.yml")

puts Time.now.to_s + " " + "--------------------ARBITRAGER--------------------"
puts Time.now.to_s + " " + "Looking for order book"
config["brokers"].each_with_index do |broker, i|
  threads << Thread.new do
    if(broker["broker"] == "bitflyer")
      bf = Bitflyer.new(broker["key"], broker["secret"])
      bid_price, ask_price, bid_size, ask_size = bf.read_ticker
      boards[:bitflyer][:bid][:price] = bid_price
      boards[:bitflyer][:ask][:price] = ask_price
      boards[:bitflyer][:bid][:size] = bid_size
      boards[:bitflyer][:ask][:size] = ask_size
    elsif(broker["broker"] == "coincheck")
      cc = Coincheck.new(broker["key"], broker["secret"])
      bid_price, ask_price, bid_size, ask_size = cc.read_ticker
      boards[:coincheck][:bid][:price] = bid_price
      boards[:coincheck][:ask][:price] = ask_price
      boards[:coincheck][:bid][:size] = bid_size
      boards[:coincheck][:ask][:size] = ask_size
    end
  end
end

threads.each { |th| th.join }
boards.each do |broker|
  max = broker[1][:bid][:price].to_i
  min = broker[1][:ask][:price].to_i
  if(best_bid_price.nil? || best_bid_price < max)
    best_bid_broker = broker[0]
    best_bid_price = max
    best_bid_size = BigDecimal(broker[1][:bid][:size].to_s).floor(3).to_f
  end
  if(best_ask_price.nil? || best_ask_price > min)
    best_ask_broker = broker[0]
    best_ask_price = min
    best_ask_size = BigDecimal(broker[1][:ask][:size].to_s).floor(3).to_f
  end
end

puts Time.now.to_s + " " + "Best bid: " + best_bid_broker.to_s.ljust(10) + best_bid_price.to_s + " " + best_bid_size.to_s
puts Time.now.to_s + " " + "Best ask: " + best_ask_broker.to_s.ljust(10) + best_ask_price.to_s + " " + best_ask_size.to_s