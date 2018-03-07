require 'net/http'
require 'uri'
require 'json'
require 'jwt'
require 'openssl'

uri = URI.parse('https://api.quoine.com')
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true

token_id = '328614'
user_secret = 'uUkbljM1jytzZhxTcVnrk0pyorWKCwjTOKnjGsEj0cORwLrbTvTr8H14OuHDx6CWQy6h36a5A5/8+9QPHyc0yw=='
path = '/orders'

auth_payload = {
  path: path,
  nonce: Time.now.to_i.to_s,
  token_id: token_id
}

body = {
  order: {
    order_type: 'limit',
    product_id: 5,
    side: 'buy',
    quantity: 0.01,
    price: 100000
  }
}.to_json

signature = JWT.encode(auth_payload, user_secret, 'HS256')

request = Net::HTTP::Post.new(path)
request.add_field('X-Quoine-API-Version', '2')
request.add_field('X-Quoine-Auth', signature)
request.add_field('Content-Type', 'application/json')
request.body = body

response = https.request(request)
result = JSON.parse(response.body)

puts result