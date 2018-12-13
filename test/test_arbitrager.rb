require_relative './lib/broker_adapter'

# This class is main component.
class Arbitrager
  def initialize
    @broker_adapter = BrokerAdapter.new
  end

  def start
    @broker_adapter.create_threads('board')
  end
end

arbitrager = Arbitrager.new
arbitrager.start
