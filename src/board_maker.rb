require_relative "broker"

class BoardMaker
  def call_broker(broker)
    response = Broker.new.get_order_book(broker)
    converge(*response)
  end

  private
  
    def converge(bids, asks)
      best_bid = bids[0][0].to_i.floor(-2)
      best_ask = asks[0][0].to_i.ceil(-2)
      bid_amount = bids.select { |price, amount| price.to_i >= best_bid }.transpose[1].map(&:to_f).sum.floor(3)
      ask_amount = asks.select { |price, amount| price.to_i <= best_ask }.transpose[1].map(&:to_f).sum.floor(3)
      best_bid = bids[0][0].to_i.ceil(-2)
      best_ask = asks[0][0].to_i.floor(-2)
      return { bid: best_bid, bid_amount: bid_amount, ask: best_ask, ask_amount: ask_amount }
    end
end