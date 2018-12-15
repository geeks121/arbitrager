require_relative "broker"

class PositionMaker
  def call_broker(broker)
    response = Broker.new.get_balance(broker)
    return { position: response }
  end
end