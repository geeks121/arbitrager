require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class SystemTrade
  def initialize(key, secret)
    @key = key
    @secret = secret
  end

  def request_for_get(uri, headers = {})
    request = Net::HTTP::Get.new(uri.request_uri, initheader = custom_header(headers))
    request_http(uri, request)
  end

  def request_for_post(uri, headers, body)
    request = Net::HTTP::Post.new(uri.request_uri, initheader = custom_header(headers))
    request.body = body.to_json
    request_http(uri, request)
  end

  def request_http(uri, request)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    response = https.request(request)
    JSON.parse(response.body)
  end
end
