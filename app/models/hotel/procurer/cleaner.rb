class Hotel::Procurer::Cleaner
  def self.clean(data)
    if data.is_a?(Hash)
      data.transform_values do |value|
        clean(value)
      end
    elsif data.is_a?(Array)
      data.map { |e| clean(e) }
    elsif data.is_a?(String)
      data.strip
    else
      data
    end
  end

  def self.clean_one(data)
  end
end
