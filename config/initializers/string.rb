class String
  def extract_float
    self.gsub(/[^\d^\.]/, '').to_f
  end

  def extract_percent
    return nil if self.blank?
    self.gsub(/[^\d]/, '').to_f / 100
  end

  def extract_currency
    return nil if self.blank?
    self.extract_float
  end
end
