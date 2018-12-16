require_relative "exchanges/coincheck"
require_relative "exchanges/liquid"


class Broker
  def get_order_book(broker)
    Object.const_get(broker[:broker]).new.get_order_book(broker)
  end
  
  def get_balance(broker)
    Object.const_get(broker[:broker]).new.get_balance(broker)
  end

  def order_market(broker, price, amount)
    Object.const_get(broker[:broker]).new.order_market
  end
end