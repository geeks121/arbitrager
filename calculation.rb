class Calculation
  def initialize
    @today = Time.now.strftime("%Y-%m-%d")
    @yesterday = 15.hours.ago.strftime("%Y-%m-%d")
  end

  def start
    puts "calculation start"
    today_data, yesterday_data = select_exchange_information
    total_jpy_balance, total_balance, profit, profit_rate = calculate_profit(today_data, yesterday_data)
    puts "calculation end"
    return total_jpy_balance, total_balance, profit, profit_rate
  end

  def select_exchange_information
    today_data = ExchangeInformation.where("created_on = '#{@today}'")
    yesterday_data = ExchangeInformation.where("created_on = '#{@yesterday}'")
    return today_data, yesterday_data
  end

  def calculate_profit(today_data, yesterday_data)
    total_jpy_balance = today_data.sum(:jpy_balance)
    total_btc_to_jpy_balance = today_data.sum(:btc_to_jpy_balance)
    total_balance = total_jpy_balance + total_btc_to_jpy_balance
    if yesterday_data.present?
      yesterday_total_jpy_balance = yesterday_data.sum(:jpy_balance)
      yesterday_total_btc_to_jpy_balance = yesterday_data.sum(:btc_to_jpy_balance)
      yesterday_total_balance = yesterday_total_jpy_balance + yesterday_total_btc_to_jpy_balance
      btc_difference = total_btc_to_jpy_balance - yesterday_total_btc_to_jpy_balance
      profit = (total_balance - yesterday_total_balance - btc_difference).floor.to_f
      profit_rate = (profit / total_balance * 100).truncate(3)
    end

    return total_jpy_balance, total_balance, profit, profit_rate
  end

  def confirm_difference_btc_amount(today_data, bit_base_amount)
    original_today_data = today_data
    today_data.each_with_index do |data, index|
      # data[2] is bit balance
      unless bit_base_amount == data[2]
        calclation_data = (bit_base_amount * 1000 - data[2] * 1000) / 1000
        if calclation_data >= 0
          original_today_data[index].push(calclation_data, "buy")
        else
          original_today_data[index].push(calclation_data.abs, "sell")
        end
      end
    end
    return original_today_data
  end
end
