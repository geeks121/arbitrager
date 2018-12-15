require_relative "broker"

class PositionMaker
  def call_broker(broker)
    response = Broker.new.get_balance(broker)
  end
end