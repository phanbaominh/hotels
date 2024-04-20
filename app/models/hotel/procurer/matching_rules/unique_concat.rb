module Hotel::Procurer::MatchingRules
  class UniqueConcat < Base
    def initialize(&uniq_by)
      @uniq_by = uniq_by || :itself
    end

    private

    attr_reader :uniq_by

    def _apply(data)
      data.field_values.flatten.uniq(&uniq_by)
    end
  end
end
