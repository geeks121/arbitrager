require "net/http"
require "uri"
require "json"
require "openssl"
require "Base64"
require "./password"

key = Base64.decode64($bitflyer_encryption_key)
secret = Base64.decode64($bitflyer_encryption_secret)

timestamp = Time.now.to_i.to_s
method = "POST"
uri = URI.parse("https://api.bitflyer.jp")
uri.path = "/v1/me/sendchildorder"
body = {
  product_code: "BTC_JPY",
  child_order_type: "LIMIT",
  side: "BUY",
  price: 30000,
  size: 0.1,
  minute_to_expire: 43200,
  time_in_force: "GTC"
}.to_json

text = timestamp + method + uri.request_uri + body
sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, text)

options = Net::HTTP::Post.new(uri.request_uri, initheader = {
  "ACCESS-KEY" => key,
  "ACCESS-TIMESTAMP" => timestamp,
  "ACCESS-SIGN" => sign,
  "Content-Type" => "application/json"
})

options.body = body
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
response = https.request(options)
puts response.body