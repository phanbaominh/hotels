module Hotel::Procurer::MatchingRules
  class RuleData
    attr_reader :field, :data

    def initialize(field, data)
      @field = field
      @data = data.compact
    end

    def field_values
      @field_values ||= data.pluck(field).compact
    end

    def method_missing(method, ...)
      if data.respond_to?(method)
        data.send(method, ...)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      data.respond_to?(method) || super
    end

    def field_value_of(supplier)
      data.find { |d| d[Hotel::Procurer::SUPPLIER_KEY] == supplier }&.dig(field)
    end
  end

  class Base
    def apply(field, data)
      data = RuleData.new(field, data)

      return data.field_values.first if data.field_values.size == 1

      _apply(data)
    end
  end
end
