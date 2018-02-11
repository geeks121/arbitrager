require_relative 'system_trade'

class Bitflyer < SystemTrade
  @@base_url = "https://api.bitflyer.jp"

  def get_order_books
    uri = URI.parse(@@base_url + "/v1/getboard")
    headers = get_signature(uri, @key, @secret)
    response = request_for_get(uri, headers)
    return response["bids"][0]["price"], response["asks"][0]["price"],
            response["bids"][0]["size"], response["asks"][0]["size"] 
  end

  def get_signature(uri, key, secret, body = "")
    timestamp = Time.now.to_i.to_s
    message = timestamp + uri.to_s + body
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, message)
    headers = {
      "ACCESS-KEY" => key,
      "ACCESS-TIMESTAMP" => timestamp,
      "ACCESS-SIGN" => signature
    }
  end

  def custom_header(headers = {})
    headers.merge!({
      "Content-Type" => "application/json"
    })
  end
end