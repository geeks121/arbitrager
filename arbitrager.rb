require 'yaml'
require 'json'
require 'bundler/setup'
require_relative './lib/bitflyer'
require_relative './lib/coincheck'

best_bid_broker, best_ask_broker = nil
best_bid_price, best_ask_price = nil
best_bid_size, best_ask_size = nil
threads = []
bitflyer = nil
coincheck = nil
tickers = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
config = YAML.load_file('./etc/config.yml')

puts Time.now.to_s + ' ' + 'Starting the service...'
puts Time.now.to_s + ' ' + 'Starting Arbitrager...'
puts Time.now.to_s + ' ' + '--------------------ARBITRAGER--------------------'
puts Time.now.to_s + ' ' + 'Looking for order books'
config['brokers'].each do |broker|
  threads << Thread.new do
    if broker['broker'] == 'bitflyer'
      bitflyer = Bitflyer.new(broker['key'], broker['secret'])
      bid_price, ask_price, bid_size, ask_size = bitflyer.get_order_books
      tickers['bitflyer']['bid']['price'] = bid_price
      tickers['bitflyer']['ask']['price'] = ask_price
      tickers['bitflyer']['bid']['size'] = bid_size
      tickers['bitflyer']['ask']['size'] = ask_size
    elsif broker['broker'] == 'coincheck'
      coincheck = Coincheck.new(broker['key'], broker['secret'])
      bid_price, ask_price, bid_size, ask_size = coincheck.get_order_books
      tickers['coincheck']['bid']['price'] = bid_price
      tickers['coincheck']['ask']['price'] = ask_price
      tickers['coincheck']['bid']['size'] = bid_size
      tickers['coincheck']['ask']['size'] = ask_size
    end
  end
end

threads.each(&:join)
tickers.each do |broker|
  max = broker[1]['bid']['price'].to_i
  min = broker[1]['ask']['price'].to_i
  if best_bid_price.nil? || best_bid_broker != broker[0] \
      && best_bid_price < max
    best_bid_broker = broker[0]
    best_bid_price = max
    best_bid_size = broker[1]['bid']['size'].to_f.floor(3)
  end

  next unless best_ask_price.nil? || best_ask_broker != broker[0] \
                && best_ask_price > min
  best_ask_broker = broker[0]
  best_ask_price = min
  best_ask_size = broker[1]['ask']['size'].to_f.floor(3)
end

mid_price = (best_bid_price + best_ask_price) / 2
spread = best_bid_price - best_ask_price
available_volume = best_bid_size < best_ask_size ? best_bid_size : best_ask_size
expected_profit = ((best_bid_price - best_ask_price) \
                    * available_volume).floor(3)
profit_percent = expected_profit / (mid_price * available_volume) * 100

if available_volume > config['maxsize']
  target_volume = config['maxsize']
elsif available_volume < config['minsize']
  puts 'exit'
  exit
else
  target_volume = available_volume
end

puts Time.now.to_s + ' ' + 'Best ask: ' + best_ask_broker.to_s.ljust(10) \
      + best_ask_price.to_s + ' ' + best_ask_size.to_s
puts Time.now.to_s + ' ' + 'Best bid: ' + best_bid_broker.to_s.ljust(10) \
      + best_bid_price.to_s + ' ' + best_bid_size.to_s
puts Time.now.to_s + ' ' + 'Spread: ' + spread.to_s
puts Time.now.to_s + ' ' + 'Available volume: ' + available_volume.to_s
puts Time.now.to_s + ' ' + 'Target volume: ' + target_volume.to_s
puts Time.now.to_s + ' ' + 'Expected profit: ' + expected_profit.to_s
puts 'profit percent: ' + profit_percent.to_s

if profit_percent < config['minTargetProfitPercent']
  puts 'exit'
  exit
end

puts Time.now.to_s + ' ' + '>> Found arbitrage oppotunity.'
puts Time.now.to_s + ' ' + '>> Sending order targetting quote ' \
      + best_ask_broker.to_s.ljust(10) + best_ask_price.to_s \
      + ' ' + best_ask_size.to_s
puts Time.now.to_s + ' ' + '>> Sending order targetting quote ' \
      + best_bid_broker.to_s.ljust(10) + best_bid_price.to_s \
      + ' ' + best_bid_size.to_s

[best_ask_broker, best_bid_broker].each do |broker|
  case broker
  when 'bitflyer'
    puts 'bitflyer'
  when 'coincheck'
    temp = coincheck.send_order(order_type: 'buy',
                                rate: best_ask_price,
                                amount: target_volume)
  end
end
