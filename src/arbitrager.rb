require "yaml"
require_relative "board_maker"
require_relative "position_maker"
require_relative "spread_analyzer"
require_relative "deal_maker"
require_relative "broker"

class Arbitrager
  def initialize
    @deal_record = []
    @deal_record[0] = {:bid_broker=>"Coincheck", :ask_broker=>"Liquid", :amount=>0.06, :profit=>96, :profit_rate=>0.152}
    @format = "%Y-%m-%d %H:%M:%S"
    @info = "INFO"
    @config = YAML.load_file("../config.yml")
    @retry_count = 3
  end

  def start
    output_info("Starting the serivce...")
    output_info("Starting Arbitrager...")
    output_info("Started Arbitrager.")
    output_info("Successfully started the service.")
    #loop do
    #  sleep 3
      call_arbitrager
    #end
  end

  def stop
    output_info("Stopping Arbitrager...")
    output_info("Stopping the service...")
    output_info("Stopped Arbitrager.")
    output_info("Successfully stopped the service.")
    exit(0)
  end

  Signal.trap(:INT) do
    Arbitrager.new.stop
  end

  private

    def call_arbitrager
      threads = []
      @config[:brokers].map do |broker|
        threads << Thread.new do
          call_board_and_position_maker(broker)
        end
      end
      
      threads.each(&:join)
      if @deal_record.length > 0
        output_record(@deal_record)
        close_result = call_closing(@config, @deal_record)
      end

      output_position(@config[:brokers])
      analysis_result = call_spread_analyzer(@config)
      deal_result = call_deal_maker(@config, analysis_result)
      output_board(@config[:target_amount], analysis_result, deal_result[:message])
      if close_result[:reason] == "Closing"
        call_broker(@config, close_result)
      else
        #call_broker(@config, analysis_result) if deal_result[:reason] == "High profit"
      end
    end

    def call_board_and_position_maker(broker)
      broker.merge!(BoardMaker.new.call_broker(broker))
      broker.merge!(PositionMaker.new.call_broker(broker))
    end

    def call_spread_analyzer(config)
      SpreadAnalyzer.new.analyze(config)
    end

    def call_closing(config, deal_record)
      bid_broker, bid, ask_broker, ask, profit, index, deal_result = nil
      deal_record.each_with_index do |record, i|
        config[:brokers].each do |broker|
          case broker[:broker]
          when record[:bid_broker]
            ask_broker = broker[:broker]
            ask = broker[:ask]
          when record[:ask_broker]
            bid_broker = broker[:broker]
            bid = broker[:bid]
          end
        end

        if profit.nil? || profit < record[:profit]
          profit = SpreadAnalyzer.new.close_analyze_profit(bid, ask, record[:amount])
          deal_result = DealMaker.new.confirm_closing_record(profit, record[:profit], config[:exit_profit_rate])
          index = i
        end
      end


      return { bid_broker: bid_broker, best_bid: bid, ask_broker: ask_broker, best_ask: ask,
               index: index, profit: profit, reason: deal_result[:reason], message: deal_result[:message] }
    end

    def call_deal_maker(config, analysis_result)
      DealMaker.new.decide(config, analysis_result)
    end

    def call_broker(config, a_result)
      output_info(">> Sending order targetting price #{a_result[:bid_broker]} Bid #{a_result[:best_bid]}")
      output_info(">> Sending order targetting price #{a_result[:ask_broker]} Bid #{a_result[:best_ask]}")    
      # steps in Nonce must be incremented by coincheck.
      sleep 1
      threads = []
      config[:brokers].each do |broker|
        threads << Thread.new do
          case broker[:broker]
          when a_result[:bid_broker]
            #broker.merge!(Broker.new.order_market(broker, a_result[:best_ask], config[:target_amount], "buy"))
            #broker.merge!(Broker.new.order_market(broker, 100, config[:target_amount], "buy"))
          when a_result[:ask_broker]
            #broker.merge!(Broker.new.order_market(broker, a_result[:best_bid], config[:target_amount], "sell"))
            #broker.merge!(Broker.new.order_market(broker, 10000000, config[:target_amount], "sell"))
          end
        end
      end

      threads.each(&:join)
      check_order_status(config, a_result)
    end

    def check_order_status(config, a_result)
      pending = nil
      1.upto(@retry_count) do |count|
        output_info(">> Order check attempt #{count}")
        output_info(">> Checking if both legs are done or not...")
        sleep 1
        threads = []
        config[:brokers].each do |broker|
          threads << Thread.new do
            broker.merge!(Broker.new.get_order_status(broker))
          end
        end

        threads.each(&:join)
        config[:brokers].each do |broker|
          case broker[:broker]
          when a_result[:bid_broker]
            if broker[:order_status].nil?
              output_info(">> Filled: #{a_result[:bid_broker]} Buy at #{a_result[:best_bid]}")
            else
              output_info(">> Pending: #{a_result[:bid_broker]} Buy at #{a_result[:best_bid]}")
              pending = a_result[:bid_broker]
            end
          when a_result[:ask_broker]
            if broker[:order_status].nil?
              output_info(">> Filled: #{a_result[:ask_broker]} Sell at #{a_result[:best_ask]}")
            else
              output_info(">> Pending: #{a_result[:ask_broker]} Sell at #{a_result[:best_ask]}")
              pending = a_result[:ask_broker]
            end
          end
        end

        break if pending.nil?
      end

      if pending.nil?
        if a_result[:reason] == "Closing"
          @deal_record.delete_at(a_result[:index])
        else
          @deal_record[@deal_record.length] = { bid_broker: a_result[:bid_broker], ask_broker: a_result[:ask_broker],
                                                amount: config[:target_amount], profit: a_result[:profit], profit_rate: a_result[:profit_rate]}
        end
        
        output_info(">> Both legs are successfully filled.")
        output_info(">> Buy filled price is #{a_result[:best_bid]}")
        output_info(">> Sell filled price is #{a_result[:best_ask]}")
        output_info(">> Profit is #{a_result[:profit]}")
      else
        config[:brokers].each do |broker|
          if broker[:broker] == pending
            sleep 1
            Broker.new.cancel_order(broker)
          end
        end
      end
    end

    def call_record_holder
    end

    def output_info(message)
      puts "#{Time.now.strftime(@format)} #{@info} #{message}"
    end

    def output_position(brokers)
      output_info("#{'POSITION'.center(50, '-')}")
      brokers.each do |broker|
        output_info("#{broker[:broker].ljust(10)} : #{broker[:position]} BTC") 
      end

      output_info("#{'-'.center(50, '-')}")
    end

    def output_board(target_amount, a_result, d_result)
      output_info("#{'ARBITRAGER'.center(50, '-')}")
      output_info("Looking for opportunity...")
      output_info("#{'Best bid'.ljust(18)} : #{a_result[:bid_broker].ljust(10)} Bid #{a_result[:best_bid]} #{a_result[:bid_amount]}")
      output_info("#{'Best ask'.ljust(18)} : #{a_result[:ask_broker].ljust(10)} Ask #{a_result[:best_ask]} #{a_result[:ask_amount]}")
      output_info("#{'Spread'.ljust(18)} : #{a_result[:spread]}")
      output_info("#{'Available amount'.ljust(18)} : #{a_result[:available_amount]}")
      output_info("#{'Target amount'.ljust(18)} : #{target_amount}")
      output_info("#{'Expected profit'.ljust(18)} : #{a_result[:profit]} (#{a_result[:profit_rate]}%)")
      output_info("#{d_result}")
    end

    def output_record(d_record)
      output_info("#{'RECORD'.center(50, '-')}")
      d_record.each do |record|
        output_info("Buy: #{record[:bid_broker]} Sell: #{record[:ask_broker]} Amount: #{record[:amount]} Profit: #{record[:profit]} (#{record[:profit_rate]}%)")
      end

      output_info("#{'-'.center(50, '-')}")
    end
end

arbitrager = Arbitrager.new
arbitrager.start