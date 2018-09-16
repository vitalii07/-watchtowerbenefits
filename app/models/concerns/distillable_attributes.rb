# Adds helper methods for getting / settings values and selectors for attributes.
# attribute arguments is a DynamicAttribute

module DistillableAttributes
  def selector_for_attribute(attribute)
    dynamic_value_for(attribute).try(:selector)
  end

  def display_name_for_attribute(attribute)
    attribute.display_name
  end

  def value_for_attribute(attribute)
    dynamic_value_for(attribute).try(:value)
  end

  def dynamic_value_for(attribute)
    @values ||= Hash.new.tap do |hash|
      dynamic_values.group_by(&:dynamic_attribute_id).each do |da_id, values|
        if values.first.compound
          value = values.inject({}) {|acc, val| acc[val.label] = val.value; acc }
          hash[da_id] = ::AgeBanded.new(value: value, comparison_flag: values.first.comparison_flag)
        else
          hash[da_id] = values.first
        end
      end
    end

    @values[attribute.try(:id)]
  end
end
