require "net/http"
require "uri"
require "openssl"
require "Base64"
require "./password"

key = Base64.decode64($encryption_key)
secret = Base64.decode64($encryption_secret)

timestamp = Time.now.to_i.to_s
method = "GET"
uri = URI.parse("https://api.bitflyer.jp")
uri.path = "/v1/me/getbalance"

text = timestamp + method + uri.request_uri
sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, text)

options = Net::HTTP::Get.new(uri.request_uri, initheader = {
  "ACCESS-KEY" => key,
  "ACCESS-TIMESTAMP" => timestamp,
  "ACCESS-SIGN" => sign,
});

https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
response = https.request(options)
puts response.body