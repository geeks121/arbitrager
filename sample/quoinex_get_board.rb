require 'net/http'
require 'uri'
require 'json'
require 'jwt'

uri = URI.parse('https://api.quoine.com')
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true

token_id = '328614'
user_secret = 'uUkbljM1jytzZhxTcVnrk0pyorWKCwjTOKnjGsEj0cORwLrbTvTr8H14OuHDx6CWQy6h36a5A5/8+9QPHyc0yw=='
path = '/products/5/price_levels'

auth_payload = {
  path: path,
  nonce: Time.now.to_i.to_s,
  token_id: token_id
}

signature = JWT.encode(auth_payload, user_secret, 'HS256')

request = Net::HTTP::Get.new(path)
request.add_field('X-Quoine-API-Version', '2')
request.add_field('X-Quoine-Auth', signature)
request.add_field('Content-Type', 'application/json')

response = https.request(request)
result = JSON.parse(response.body)

bid = result['buy_price_levels'][0]
ask = result['sell_price_levels'][0]

print bid
puts "\n-----"
print ask


