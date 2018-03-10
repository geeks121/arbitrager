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
    @config['brokers'].each do |_broker|
      threads << Thread.new do
         case method
      when 'board' then fetch_board
      when 'order' then puts 'order'
      end
    end
  end
end
　　