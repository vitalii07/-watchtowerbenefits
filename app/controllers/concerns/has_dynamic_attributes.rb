module HasDynamicAttributes
  extend ActiveSupport::Concern

  def update_dynamic_attribute(obj)
    # TODO revise this
    dynamic_value = nil
    if params[:attribute_id] && params[:attribute_value]
      column = params[:column_name] || :value
      da = DynamicAttribute.find(params[:attribute_id])

      if column == 'is_atp_rate'
        params[:attribute_value] = params[:attribute_value] == 'true'
      end

      if params[:attribute_value].is_a? Hash
        label = params[:attribute_value].keys.first
        value = params[:attribute_value].values.first
      end
      label ||= params[:label]
      value ||= params[:attribute_value]
      dynamic_value = obj.dynamic_values.find_or_initialize_by(
        dynamic_attribute_id: da.id,
        label: label,
        compound: label.present?
      )
      dynamic_value.update(column => value, :selector => params[:selector])
    end
    dynamic_value
  end
end
