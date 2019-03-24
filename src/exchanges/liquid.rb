require "net/http"
require "uri"
require "openssl"
require "json"
require "jwt"

class Liquid
  def initialize
    @base_url = "https://api.liquid.com"
    @BTC_JPY = 5
  end

  def start
    puts "#{@name} start"
    btc_price = get_ticker
    jpy_balance, btc_balance = get_balance
    puts "#{@name} end "
    return @name, jpy_balance, btc_balance, btc_price
  end

  def check_order_market(broker, price, amount, order_type)
    order_market(broker, order: "market", amount: amount, order_type: order_type)
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

  def get_order_status(broker)
    uri = URI.parse(@base_url)
    path = "/orders/#{broker['id']}"
    signature = get_signature(path, broker[:key], broker[:secret])
    response = request_for_get(uri, path, signature)
    { broker: broker[:broker],  order_status: response.dig("status") }
  end

=begin
  def get_order_history(broker)
    uri = URI.parse(@base_url)
    path = "/orders/800753984"
    signature = get_signature(path, broker[:key], broker[:secret])
    response = request_for_get(uri, path, signature)
    return { broker: broker[:broker], amount: response["quantity"], order_type: response["side"] }
  end
=end

  def order_market(broker, order: "limit", price: nil, amount: nil, order_type: nil)
    uri = URI.parse(@base_url)
    path = "/orders/"
    body = {
      order_type: order,
      product_id: @BTC_JPY,
      side: order_type,
      price: price,
      quantity: amount,
    }.to_json
    signature = get_signature(path, broker[:key], broker[:secret])
    request_for_post(uri, path, signature, body)
  end

  def cancel_order(broker)
    uri = URI.parse(@base_url)
    path = "/orders/#{broker['id']}/cancel"
    signature = get_signature(path, broker[:key], broker[:secret])
    response = request_for_put(uri, path, signature)
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

  def request_for_put(uri, path, signature)
    request = Net::HTTP::Put.new(path)
    request.add_field("X-Quoine-API-Version", "2")
    request.add_field("X-Quoine-AUth", signature)
    request.add_field("Content-Type", "application/json")
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