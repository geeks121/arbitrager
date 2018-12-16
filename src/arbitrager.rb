require "yaml"
#require 'json'
#require 'bundler/setup'
require_relative "board_maker"
require_relative "position_maker"
require_relative "spread_analyzer"
require_relative "deal_maker"
#require_relative './lib/bitflyer'
#require_relative './lib/coincheck'

class Arbitrager
  def initialize
    @format = "%Y-%m-%d %H:%M:%S"
    @info = "INFO"
    @config = YAML.load_file("../config.yml")
  end

  def start
    output_info("Starting the serivce...")
    output_info("Starting Arbitrager...")
    call_arbitrager
  end

  def stop
    output_info("Stopping Arbitrager...")
    output_info("Stopping the service...")
    output_info("Stopped the service.")
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
      output_position(@config[:brokers])
      analysis_result = call_spread_analyzer(@config)
      deal_result = call_deal_maker(@config, analysis_result)
      output_board(@config[:target_amount], analysis_result, deal_result)
    end

    def call_board_and_position_maker(broker)
      broker.merge!(BoardMaker.new.call_broker(broker))
      broker.merge!(PositionMaker.new.call_broker(broker))
    end

    def call_spread_analyzer(config)
      SpreadAnalyzer.new.analyze(config)
    end

    def call_deal_maker(config, analysis_result)
      DealMaker.new.decide(config, analysis_result)
    end

    def call_broker
    end

    def call_record_holder
    end
  
    def output_info(message)
      puts "#{Time.now.strftime(@format)} #{@info} #{message}"
    end

    def output_position(brokers)
      output_info("---------------------POSITION---------------------")
      brokers.each do |broker|
        output_info("#{broker[:broker].ljust(10)} : #{broker[:position]} BTC") 
      end

      output_info("--------------------------------------------------")
    end

    def output_board(target_amount, a_result, d_result)
      output_info("--------------------ARBITRAGER--------------------")
      output_info("Looking for opportunity...")
      output_info("#{'Best bid'.ljust(18)} : #{a_result[:bid_broker].ljust(10)} Bid #{a_result[:best_bid]} #{a_result[:bid_amount]}")
      output_info("#{'Best ask'.ljust(18)} : #{a_result[:ask_broker].ljust(10)} Ask #{a_result[:best_ask]} #{a_result[:ask_amount]}")
      output_info("#{'Spread'.ljust(18)} : #{a_result[:spread]}")
      output_info("#{'Available amount'.ljust(18)} : #{a_result[:available_amount]}")
      output_info("#{'Target amount'.ljust(18)} : #{target_amount}")
      output_info("#{'Expected profit'.ljust(18)} : #{a_result[:profit]} (#{a_result[:profit_rate]}%)")
      output_info("#{d_result}")
    end
end

arbitrager = Arbitrager.new
arbitrager.start