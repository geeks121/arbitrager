require "yaml"
#require 'json'
#require 'bundler/setup'
require_relative "board_maker"
require_relative "position_maker"
require_relative "spread_analyzer"
require_relative "deal_marker"
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
          call_maker(broker)
        end
      end
      
      threads.each(&:join)
      output_position(@config[:brokers])
      analysis_result = call_spread_analyzer(@config)
      call_deal_marker(@config, analysis_result)
      output_board(@config[:target_amount], analysis_result)
    end

    def call_maker(broker)
      broker.merge!(BoardMaker.new.call_broker(broker))
      broker.merge!(PositionMaker.new.call_broker(broker))
    end

    def call_spread_analyzer(config)
      SpreadAnalyzer.new.analyze(config)
    end

    def call_deal_marker(config, analysis_result)
      DealMarker.new.decide(config, analysis_result)
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
      output_info("------------------------------------------------")
    end

    def output_board(target_amount, result)
      output_info("--------------------ARBITRAGER--------------------")
      output_info("Looking for opportunity...")
      output_info("#{'Best bid'.ljust(18)} : #{result[:bid_broker].ljust(10)} Bid #{result[:best_bid]} #{result[:bid_amount]}")
      output_info("#{'Best ask'.ljust(18)} : #{result[:ask_broker].ljust(10)} Ask #{result[:best_ask]} #{result[:ask_amount]}")
      output_info("#{'Spread'.ljust(18)} : #{result[:spread]}")
      output_info("#{'Available amount'.ljust(18)} : #{result[:available_amount]}")
      output_info("#{'Target amount'.ljust(18)} : #{target_amount}")
      output_info("#{'Expected profit'.ljust(18)} : #{result[:profit]} (#{result[:profit_rate]}%)")
    end
end

arbitrager = Arbitrager.new
arbitrager.start