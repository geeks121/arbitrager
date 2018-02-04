require_relative 'system_trade'

class Coincheck < SystemTrade
  @@base_url = "https://coincheck.com"

  def read_ticker
    uri = URI.parse(@@base_url + "/api/order_books")
    response = request_http(uri)
    return response["bids"][0][0], response["asks"][0][0], 
            response["bids"][0][1], response["asks"][0][1]
  end
end