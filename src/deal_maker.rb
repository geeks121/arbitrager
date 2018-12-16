class DealMaker
  def initialize
    @reason = nil
    @message = nil
  end

  def decide(config, analysis_result)
    confirm_amount(config[:target_amount], analysis_result[:available_amount])
    confirm_profit_rate(config[:profit_rate], analysis_result[:profit_rate])
    @reason ||= "High profit"
    @message ||= "Found arbitrage opportunity..."
    return { reason: @reason, message: @message }
  end

  def confirm_amount(target, result)
    if target > result
      @reason ||= "Small amount"
      @message ||= "Target amount is smaller than available amount."
    end
  end
  
  def confirm_profit_rate(target, result)
    if result <= 0 && target >= result
      @reason ||= "Low profit"
      @message ||= "Target profit is smaller than expected profit"
    end
  end
end