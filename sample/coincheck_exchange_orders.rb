require "net/http"
require "uri"
require "json"
require "openssl"
require "Base64"
require "./password"

key = Base64.decode64($coincheck_encryption_key)
secret = Base64.decode64($coincheck_encryption_secret)
version = "0.3.0"

nonce = Time.now.to_i.to_s
uri = URI.parse("https://coincheck.com/api/exchange/orders")
body = {
  pair: "btc_jpy",
  order_type: "market_buy",
  market_buy_amount: 1000,
}.to_json

text = nonce + uri.to_s + body
signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, text)

options = Net::HTTP::Post.new(uri.request_uri, initheader = {
  "ACCESS-KEY" => key,
  "ACCESS-NONCE" => nonce,
  "ACCESS-SIGNATURE" => signature,
  "Content-Type" => "application/json",
  "User-Agent" => "RubyCoincheckClient " + version
})

options.body = body
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
response = https.request(options)
puts response.body