require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://api.bitflyer.jp")
uri.path = '/v1/getticker'
uri.query = ''

https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
response = https.get uri.request_uri
result = JSON.parse(response.body)

bid = result["best_bid"]
ask = result["best_ask"]

puts bid
puts ask