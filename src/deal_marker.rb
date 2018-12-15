class DealMarker
  def decide(config, analysis_result)
    result ||= confirm_amount(config[:target_amount], analysis_result[:available_amount])
    result ||= confirm_profit_rate(config[:profit_rate], analysis_result[:profit_rate])
    result ||= "High"
  end

  def confirm_amount(target, result)
    "Few" unless target <= result
  end
  
  def confirm_profit_rate(target, result)
    "Low" unless target >= result
  end
end