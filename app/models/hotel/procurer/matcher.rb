class Hotel::Procurer::Matcher
  def initialize(rules)
    @rules = rules
  end

  def match(data)
    rules.each_with_object({}) do |(key, rule), hash|
      hash[key] = rule.apply(key, data)
    end
  end

  private

  attr_reader :rules
end
