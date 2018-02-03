require_relative 'system_trade'

class Bitflyer < SystemTrade
  @@base_url = "https://api.bitflyer.jp"

  def read_ticker
    uri = URI.parse(@@base_url + "/v1/getticker")
    response = request_http(uri)
    return response["best_bid"], response["best_ask"]
  end
end