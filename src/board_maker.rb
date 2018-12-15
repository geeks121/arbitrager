require_relative "broker"

class BoardMaker
  def call_broker(broker)
    response = Broker.new.get_ticker(broker)
    bid, ask = converge_price(*response)
    return { bid: bid, ask: ask }
  end

  private
  
    def converge_price(bid, ask)
      return bid.ceil(-2), ask.floor(-2)
    end
end