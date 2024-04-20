module Hotel::Procurer::MatchingRules
  class Nested < Base
    def initialize(sub_rules)
      @matcher ||= Hotel::Procurer::Matcher.new(sub_rules)
    end

    private

    attr_reader :matcher

    def _apply(data)
      matcher.match(data.field_values)
    end
  end
end
