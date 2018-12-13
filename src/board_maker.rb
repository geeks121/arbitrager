require_relative "broker"

class BoardMaker
  def call_broker(broker)
    Broker.new.get_ticker(broker)
  end

  private
  
    def adjust_board
    end
end