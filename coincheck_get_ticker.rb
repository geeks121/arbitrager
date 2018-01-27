require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://coincheck.com")
uri.path = '/api/ticker'
uri.query = ''

https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
response = https.get uri.request_uri
result = JSON.parse(response.body)

bid = result["bid"]
ask = result["ask"]

puts bid
puts ask