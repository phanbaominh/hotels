module Hotel::Procurer::MatchingRules
  class PickOne < Base
    private

    def _apply(data)
      data.field_values.sample
    end
  end
end
