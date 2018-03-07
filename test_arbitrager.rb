require 'yaml'

# This class is main component.
class Arbitrager
  def initialize
    @config = YAML.load_file('./etc/config.yml')
  end

  def start
    puts 'Hello World!'
  end
end

arbitrager = Arbitrager.new
arbitrager.start
