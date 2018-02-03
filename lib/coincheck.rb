require_relative 'system_trade'

class Coincheck < SystemTrade
  @@base_url = "https://coincheck.com"

  def read_ticker
    uri = URI.parse(@@base_url + "/api/ticker")
    response = request_http(uri)
    return response["bid"], response["ask"]
  end
end