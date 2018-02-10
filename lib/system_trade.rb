require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class SystemTrade
  def initialize(key, secret)
    @key = key
    @secret = secret
    @timestamp = Time.now.to_i.to_s
  end

  def request_for_post(uri, headers, body)
    request

  def request_http(uri)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    response = https.get(uri.request_uri)
    JSON.parse(response.body)
   end
end