require "yaml"
#require 'json'
#require 'bundler/setup'
require_relative "board_maker"
require_relative "position_maker"
require_relative "spread_analyzer"
#require_relative './lib/bitflyer'
#require_relative './lib/coincheck'

class Arbitrager
  def initialize
    @format = "%Y-%m-%d %H:%M:%S"
    @config = YAML.load_file("../config.yml")
  end

  def start
    output("Starting the serivce...")
    output("Starting Arbitrager...")
    call_arbitrager
  end

  def stop
    output("Stopping Arbitrager...")
    output("Stopping the service...")
    output("Stopped the service.")
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
      p @config
      call_spread_analyzer(@config)
    end

    def call_maker(broker)
      broker.merge!(BoardMaker.new.call_broker(broker))
      broker.merge!(PositionMaker.new.call_broker(broker))
    end

    def call_spread_analyzer(config)
      p SpreadAnalyzer.new.analyze(config)
    end

    def call_broker
    end

    def call_record_holder
    end

    def call_deal_marker
    end
  
    def output(message)
      puts "#{Time.now.strftime(@format)} #{message}"
    end
end

arbitrager = Arbitrager.new
arbitrager.start