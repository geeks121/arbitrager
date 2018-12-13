require "net/http"
require "uri"
require "openssl"
require "json"

class Coincheck
  def initialize
    @today = Time.now.strftime("%Y-%m-%d")
    @name = "Coincheck"
    @key = Settings.coincheck[:key]
    @secret = Settings.coincheck[:secret]
    @base_url = "https://coincheck.com"
  end

  def start
    puts "#{@name} start"
    jpy_balance, btc_balance = get_balance
    btc_price = get_ticker
    puts "#{@name} end"
    return @name, jpy_balance, btc_balance, btc_price
  end

  def check_order_argument(data)
    # data[0] is exchange name
    # data[3] is bit price
    # data[4] is order amount
    # data[5] is order type
    puts "Start check order argument in #{data[0]}"
    return unless data[5] && data[4] > 0.005
    if data[5] == "buy"
      order_market(order_type: "market_buy", market_buy_amount: data[3] * data[4])
    else
      order_market(order_type: "market_sell", amount: data[4])
    end

    puts "End check order argument in #{data[0]}"
  end

  def get_ticker
    uri = URI.parse(@base_url + "/api/ticker")
    headers = get_signature(uri, @key, @secret)
    response = request_for_get(uri, headers)
    response["last"].to_i.floor
  end

  def get_balance
    uri = URI.parse(@base_url + "/api/accounts/balance")
    headers = get_signature(uri, @key, @secret)
    response = request_for_get(uri, headers)
    return response["jpy"].to_i.floor, response["btc"].to_f.truncate(3)
  end

  def order_market(order_type: nil, market_buy_amount: nil, amount: nil)
    uri = URI.parse(@base_url + "/api/exchange/orders")
    body = {
      market_buy_amount: market_buy_amount,
      amount: amount,
      order_type: order_type,
      pair: "btc_jpy"
    }.to_json
    headers = get_signature(uri, @key, @secret, body)
    response = request_for_post(uri, headers, body)
    puts response
  end

  def get_signature(uri, key, secret, body = "")
    timestamp = Time.now.to_i.to_s
    message = timestamp + uri.to_s + body
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, message)
    headers = {
      "ACCESS-KEY" => key,
      "ACCESS-NONCE" => timestamp,
      "ACCESS-SIGNATURE" => signature
    }
  end

  def request_for_get(uri, headers = {})
    request = Net::HTTP::Get.new(uri.request_uri, initheader = custom_header(headers))
    request_http(uri, request)
  end

  def request_for_post(uri, headers = {}, body)
    request = Net::HTTP::Post.new(uri.request_uri, initheader = custom_header(headers))
    request.body = body
    request_http(uri, request)
  end

  def custom_header(headers = {})
    headers.merge!({
      "Content-Type" => "application/json",
      "User-Agent" => "RubyCoincheckClient v0.3.0"
    })
  end

  def request_http(uri, request)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    response = https.start { |http| http.request(request) }
    JSON.parse(response.body)
  end
end
