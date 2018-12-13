require_relative "exchanges/*"

class Broker
  def get_ticker(broker)
    Object.const_get(broker["broker"]).new.get_ticker
  end
  
  def get_balance(broker)
    Object.const_get(broker["broker"]).new.get_balance
  end

  def order_market(broker)
    Object.const_get(broker["broker"]).new.order_market
  end
end