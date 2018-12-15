class SpreadAnalyzer
  def initialize
    @best_bid = nil
    @best_ask = nil
    @best_amount = nil
  end

  def analyze(config)
    config[:brokers].each do |broker|
      analyze_price(broker)
    end

    spread = @best_bid - @best_ask
    return { best_bid: @best_bid, best_ask: @best_ask, best_amount: @best_amount, spread: spread }
  end

  def analyze_price(broker)
    @best_bid ||= branalyze_spreadoker[:bid]
    @best_ask ||= broker[:ask]
    if @best_bid < broker[:bid]
      @best_bid = broker[:bid] 
      analyze_amountanalyze_spread(broker[:bid_amount])
    end

    if @best_ask > broker[:ask]
      @best_ask = broker[:ask]
      analyze_amount(broker[:ask_amount])
    end
  end
  
  def analyze_amount(amount)
    @best_amount ||= amount
    @best_amount = amount if @best_amount < amount
  end
end