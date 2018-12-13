class DatabaseOperation
  def initialize
    @today = Time.now.strftime("%Y-%m-%d")
  end

  def insert_data_to_exchange_information(today_data)
    today_data.each do |array|
      ei = ExchangeInformation.new
      ei.created_on = @today
      ei.name = array[0]
      ei.jpy_balance = array[1]
      ei.btc_balance = array[2]
      ei.btc_price = array[3]
      ei.btc_to_jpy_balance = (array[2] * array[3]).floor
      ei.save
    end
  end

  def insert_data_to_profit(total_jpy_balance, total_balance, profit, profit_rate)
    pr = Profit.new
    pr.created_on = @today
    pr.total_jpy_balance = total_jpy_balance
    pr.total_balance = total_balance
    pr.profit = profit ||= 0
    pr.profit_rate = profit_rate ||= 0
    pr.save
  end
end