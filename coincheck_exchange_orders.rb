require "net/http"
require "uri"
require "json"
require "openssl"
require "Base64"
require "./password"

key = Base64.decode64($coincheck_encryption_key)
secret = Base64.decode64($coincheck_encryption_secret)

nonce = Time.now.to_i.to_s
method = "POST"
uri = URI.parse("https://coincheck.com")
uri.path = "/api/exchange/orders"
body = {
  pair: "btc_jpy",
  order_type: "market_buy",
  market_buy_amount: 1000,
}.to_json

text = nonce + method + uri.request_uri + body
signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, text)

options = Net::HTTP::Post.new(uri.request_uri, initheader = {
  "ACCESS-KEY" => key,
  "ACCESS-NONCE" => nonce,
  "ACCESS-SIGNATURE" => signature,
})

options.body = body
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
response = https.request(options)
puts response.body