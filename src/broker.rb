require_relative "exchanges/coincheck"
require_relative "exchanges/liquid"

class Broker
  def get_order_book(broker)
    Object.const_get(broker[:broker]).new.get_order_book(broker)
  end
  
  def get_balance(broker)
    Object.const_get(broker[:broker]).new.get_balance(broker)
  end

  def get_order_status(broker)
    Object.const_get(broker[:broker]).new.get_order_status(broker)
  end

  def get_order_history(broker)
    Object.const_get(broker[:broker]).new.get_order_history(broker)
  end

  def check_order_market(broker, price, amount, order_type)
    Object.const_get(broker[:broker]).new.order_market(broker, price: price, amount: amount, order_type: order_type)
  end

  def order_market(broker, price, amount, order_type)
    Object.const_get(broker[:broker]).new.order_market(broker, price: price, amount: amount, order_type: order_type)
  end

  def cancel_order(broker)
    Object.const_get(broker[:broker]).new.cancel_order(broker)
  end
end