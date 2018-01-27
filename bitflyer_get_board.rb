require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://api.bitflyer.jp")
uri.path = '/v1/getboard'
uri.query = 'product_code=BTC_JPY'

https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
response = https.get uri.request_uri
result = JSON.parse(response.body)

bid = result["bids"][0]["price"]
asks = result["asks"][0]["price"]

puts(bid)
puts(asks)