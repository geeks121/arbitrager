require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://coincheck.com")
uri.path = '/api/order_books'
uri.query = ''

https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
response = https.get uri.request_uri
result = JSON.parse(response.body)

bid = result["bids"][0]
ask = result["asks"][0]

print bid[0]
puts ask