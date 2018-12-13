require 'yaml'
require_relative 'test_bitflyer'

# This class is broker adapter.
class BrokerAdapter
  def initialize
    @config = YAML.load_file('./etc/config.yml')
  end

  def fetch_board
    puts 'brokder_adapter'
  end

  def create_threads(method)
    threads = []
    @config['brokers'].each do |broker|
      next unless broker['enabled']
      puts broker['broker']
      case method
      when 'board' then Object.const_get(broker['broker']).hello
      when 'order' then puts 'order'
      end
    end
  end
end
