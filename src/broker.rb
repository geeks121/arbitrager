require_relative "exchanges/coincheck"
require_relative "exchanges/liquid"


class Broker
  def get_ticker(broker)
    Object.const_get(broker[:broker]).new.get_ticker(broker)
  end
  
  def get_balance(broker)
    Object.const_get(broker[:broker]).new.get_balance(broker)
  end

  def order_market(broker)
    Object.const_get(broker[:broker]).new.order_market
  end
end