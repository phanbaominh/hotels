module Hotel::Procurer::MatchingRules
  class PriorityPickOne < PickOne
    def initialize(priorities)
      @priorities = priorities
    end

    private

    attr_reader :priorities

    def _apply(data)
      priorities.map do |supplier|
        data.field_value_of(supplier)
      end.compact.first || super
    end
  end
end
