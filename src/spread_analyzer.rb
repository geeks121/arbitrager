class SpreadAnalyzer
  def initialize
    @bid_broker = nil
    @ask_broker = nil
    @best_bid = nil
    @best_ask = nil
    @bid_amount = nil
    @ask_amount = nil
  end

  def analyze(config)
    config[:brokers].each do |broker|
      analyze_price(broker)
    end

    available_amount = analyze_amount(@bid_amount, @ask_amount)
    spread = analyze_spread
    profit, profit_rate = analyze_profit(spread, config[:target_amount])
    return { bid_broker: @bid_broker, best_bid: @best_bid, bid_amount: @bid_amount,
              ask_broker: @ask_broker, best_ask: @best_ask, ask_amount: @ask_amount,
              available_amount: available_amount, spread: spread, profit: profit, profit_rate: profit_rate }
  end

  def analyze_price(broker)
    @bid_broker ||= broker[:broker]
    @best_bid ||= broker[:bid]
    @bid_amount ||= broker[:bid_amount]
    @ask_broker ||= broker[:broker]
    @best_ask ||= broker[:ask]
    @ask_amount ||= broker[:ask_amount]
    if @best_bid < broker[:bid]
      @bid_broker = broker[:broker]
      @best_bid = broker[:bid]
      @bid_amount = broker[:bid_amount]
    end

    if @best_ask > broker[:ask]
      @ask_broker = broker[:broker]
      @best_ask = broker[:ask]
      @ask_amount = broker[:ask_amount]
    end
  end
  
  def analyze_amount(bid, ask)
    bid > ask ? ask : bid
  end

  def analyze_spread
    @best_bid - @best_ask
  end

  def analyze_profit(spread, amount)
    price = @best_ask * amount
    profit = (spread * amount).floor
    profit_rate = (100 * profit / price).floor(3)
    return  profit, profit_rate
  end

  def close_analyze_profit(bid, ask, amount)
    spread = bid - ask
    (spread * amount).floor
  end
end