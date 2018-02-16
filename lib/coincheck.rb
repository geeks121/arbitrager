require_relative 'system_trade'

class Coincheck < SystemTrade
  @@base_url = "https://coincheck.com"
  @@version = "0.3.0"

  def get_order_books
    uri = URI.parse(@@base_url + "/api/order_books")
    headers = get_signature(uri, @key, @secret)
    response = request_for_get(uri, headers)
    return response["bids"][0][0], response["asks"][0][0], 
            response["bids"][0][1], response["asks"][0][1]
  end

  def send_order(order_type:, rate: nil, amount: nil,
                  market_buy_amount: nil, position_id: nil, pair: 'btc_jpy')
    uri = URI.parse(@@base_url + "/api/exchange/orders")
    body = {
      rate: rate,
      amount: amount,
      market_buy: market_buy_amount,
      order_type: order_type,
      position_id: position_id,
      pair: pair
    }
    
    headers = get_signature(uri, @key, @secret, body.to_json)
    request_for_post(uri, headers, body)
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

  def custom_header(headers = {})
    headers.merge!({
      "Content-Type" => "application/json",
      "User-Agent" => "RubyCoincheckClient" + @@version
    })
  end
end