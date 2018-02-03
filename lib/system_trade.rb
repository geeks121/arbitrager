require 'net/http'
require 'uri'
require 'json'

class SystemTrade
  def initialize(key, secret)
    @key = key
    @secret = secret
  end

  def request_http(uri)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    response = https.get(uri.request_uri)
    JSON.parse(response.body)
   end
end