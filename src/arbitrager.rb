require 'yaml'
#require 'json'
#require 'bundler/setup'
require_relative "board_maker"
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
    exit(0)
  end

  Signal.trap(:INT) do
    Arbitrager.new.stop
  end

  private

    def call_arbitrager
      threads = []
      @config["brokers"].each do |broker|
        threads << Thread.new do
          call_maker(broker)
        end
      end

      threads.each(&:join)
    end

    def call_maker(broker)
      BoardMaker.new.call_broker(broker)
    end

    def call_broker
    end

    def call_record_holder
    end

    def call_spread_analyzer
    end

    def call_deal_marker
    end
  
    def output(message)
      puts "#{Time.now.strftime(@format)} #{message}"
    end
end

arbitrager = Arbitrager.new
arbitrager.start