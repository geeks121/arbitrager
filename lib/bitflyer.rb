require_relative 'system_trade'

class Bitflyer < SystemTrade
  @@base_url = "https://api.bitflyer.jp"

  def get_order_books
    uri = URI.parse(@@base_url + "/v1/getboard")
    response = request_http(uri)
    return response["bids"][0]["price"], response["asks"][0]["price"],
            response["bids"][0]["size"], response["asks"][0]["size"] 
  end
end