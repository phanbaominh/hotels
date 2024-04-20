module Hotel::Procurer::MatchingRules
  class PickLongest < Base
    private

    def _apply(data)
      data.field_values.max_by(&:length)
    end
  end
end
