require "net/http"
require "uri"
require "openssl"
require "json"
require "jwt"

class Liquid
  def initialize
    @base_url = "https://api.liquid.com"
  end

  def start
    puts "#{@name} start"
    btc_price = get_ticker
    jpy_balance, btc_balance = get_balance
    puts "#{@name} end "
    return @name, jpy_balance, btc_balance, btc_price
  end

  def check_order_argument(data)
    # data[0] is exchange name
    # data[4] is order amount
    # data[5] is order type
    puts "Start check order argument in #{data[0]}"
    order_market(order_type: data[5], amount: data[4]) if data[5]
    puts "End check order argument in #{data[0]}"
  end

  def get_ticker(broker)
    uri = URI.parse(@base_url)
    path = "/products/5"
    signature = get_signature(path, broker[:key], broker[:secret])
    response = request_for_get(uri, path, signature)
    return response["market_bid"].to_i, response["market_ask"].to_i
  end

  def get_order_book(broker)
    uri = URI.parse(@base_url)
    path = "/products/5/price_levels"
    signature = get_signature(path, broker[:key], broker[:secret])
    response = request_for_get(uri, path, signature)
    return response["buy_price_levels"], response["sell_price_levels"]
  end

  def get_balance(broker)
    uri = URI.parse(@base_url)
    path = "/accounts/balance"
    signature = get_signature(path, broker[:key], broker[:secret])
    response = request_for_get(uri, path, signature)
    search_btc(response)
  end

  def order_market(order_type: nil, amount: nil)
    uri = URI.parse(@base_url)
    path = "/orders/"
    body = {
      order_type: "market",
      product_id: 5,
      side: order_type,
      quantity: amount,
    }.to_json
    signature = get_signature(path, @key, @secret)
    response = request_for_post(uri, path, signature, body)
  end

  def get_signature(path, key, secret)
    timestamp = Time.now.to_i.to_s
    auth_payload = {
      path: path,
      nonce: timestamp,
      token_id: key
    }

    JWT.encode(auth_payload, secret, "HS256")
  end

  def request_for_get(uri, path, signature)
    request = Net::HTTP::Get.new(path)
    request.add_field("X-Quoine-API-Version", "2")
    request.add_field("X-Quoine-AUth", signature)
    request.add_field("Content-Type", "application/json")
    request_http(uri, request)
  end

  def request_for_post(uri, path, signature, body = "")
    request = Net::HTTP::Post.new(path)
    request.add_field("X-Quoine-API-Version", "2")
    request.add_field("X-Quoine-AUth", signature)
    request.add_field("Content-Type", "application/json")
    request.body = body
    request_http(uri, request)
  end

  def request_http(uri, request)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    response = https.request(request)
    JSON.parse(response.body)
  end

  def search_btc(response)
    response.each do |hash|
      return hash["balance"].to_f.floor(3) if hash.has_value?("BTC")
    end
  end
end