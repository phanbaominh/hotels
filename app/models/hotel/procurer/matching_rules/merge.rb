module Hotel::Procurer::MatchingRules
  class Merge < Base
    private

    def _apply(data)
      data.field_values.inject({}) do |hash, item|
        hash.merge(item)
      end
    end
  end
end
