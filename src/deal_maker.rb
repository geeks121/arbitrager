class DealMaker
  def initialize
    @reason = nil
    @message = nil
  end

  def decide(config, analysis_result)
    confirm_amount(config[:target_amount], analysis_result[:available_amount])
    confirm_profit_rate(config[:profit_rate], analysis_result[:profit_rate])
    @reason ||= "High profit"
    @message ||= ">> Found arbitrage opportunity..."
    return { reason: @reason, message: @message }
  end

  def confirm_amount(target, result)
    if target > result
      @reason ||= "Small amount"
      @message ||= "Target amount is smaller than available amount."
    end
  end
  
  def confirm_profit_rate(target, result)
    if result <= 0 || target >= result
      @reason ||= "Low profit"
      @message ||= "Target profit is smaller than expected profit."
    end
  end

  def confirm_closing_record(target, result, exit_profit_rate)
    closing_profit = (result * exit_profit_rate).floor - result
    if target >= closing_profit
      @reason ||= "Closing"
      @mesasge ||= "Close record for fixed profit."
    end

    return { reason: @reason, message: @message }
  end
end