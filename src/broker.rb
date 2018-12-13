require_relative "calculation.rb"
require_relative "database_operation.rb"
require_relative "coincheck.rb"
require_relative "quoinex.rb"

class Batches::Broker
  def initialize
    @exchange = %W(Coincheck Quoinex)
    @today_data = Array.new
    @bit_base_amount = 0.206
  end

  def self.call
    br = Batches::Broker.new
    br.start
  end

  def self.confirm_balance
    br = Batches::Broker.new
    br.confirm_start
  end

  def start
    puts "broker start"
    start_exchange_api
    p @today_data
    sleep 1
    adjust_balance
    @today_data = Array.new
    sleep 1
    start_exchange_api
    p @today_data
    start_database_operation
    puts "broker end"
  end

  def confirm_start
    puts "Begin confirm_start"
    start_exchange_api
    p @today_data
    sleep 1
    adjust_balance
    puts "End confirm_start"
  end

  def start_exchange_api
    threads = []
    @exchange.each do |ex|
      threads << Thread.new do
        @today_data.push(Object.const_get(ex).new.start)
      end
    end

    threads.each { |t| t.join }
  end

  def adjust_balance
    calc = Calculation.new
    order_data = calc.confirm_difference_btc_amount(@today_data, 
                                                          @bit_base_amount)
    threads = []
    order_data.each do |data|
      threads << Thread.new do
        Object.const_get(data[0]).new.check_order_argument(data)
      end
    end

    threads.each { |t| t.join }
  end

  def start_database_operation
    dbo = DatabaseOperation.new
    dbo.insert_data_to_exchange_information(@today_data)
    total_jpy_balance, total_balance, profit, profit_rate = start_calculation
    dbo.insert_data_to_profit(total_jpy_balance, total_balance, profit, profit_rate)
  end

  def start_calculation
    calc = Calculation.new
    calc.start
  end
end
