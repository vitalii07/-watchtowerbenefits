module ApplicationHelper

  def page_id
    if controller_name == 'pages' && params[:page]
      [controller_name, params[:page]].join('-')
    else
      [controller_name, action_name].join('-')
    end
  end

  def json_for(target, options = {})
    options[:scope] ||= self
    options[:url_options] ||= url_options
    ActiveModel::Serializer.serializer_for(target).new(target, options).to_json
  end

  # Gets ALL dynamic attributes that can be attached to the given object.  The results
  # are sorted according to the CARRIERS order overrides.  This is to be used in the distillery
  # when inputting data for proposals for specific carriers
  #
  # * *Args*    :
  #   - +obj+ -> object that has dynamic values
  #   - +carrier+ -> the carrier to order the attributes for
  # * *Returns* :
  #   - An array of Attributes, sorted per the carrier
  def attributes_for_carrier(obj, carrier, product_type)
    attributes = DynamicAttribute.select("dynamic_attributes.*, COALESCE(orderings.order_index, attribute_order) AS a_order")
                  .joins(:product_types)
                  .joins("LEFT JOIN orderings ON dynamic_attributes.id = orderings.parent_id
                          AND orderings.parent_type = 'DynamicAttribute' AND orderings.product_type_id = #{product_type.id}
                          AND orderings.carrier_id = #{carrier.id}")
                  .where(product_types: {id: product_type.id})
                  .order("orderings.order_index ASC NULLS LAST, a_order ASC NULLS LAST")
    attributes = attributes.where(parent_class: obj.class.name) if obj
    attributes
  end

  # Gets ALL dynamic attributes for specific products.  The results are sorted
  # and grouped by product type -> category -> array of attributes
  #
  # * *Args*    :
  #   - +product_types+ -> An array of ProductType's to find attributes for
  # * *Returns* :
  #   - The attributes grouped by their category and product
  def attributes_for_products(product_types)
    result_hash = {}
    attributes = DynamicAttribute.joins("LEFT JOIN categories ON dynamic_attributes.category_id = categories.id")
                  .includes(:product_types, :category)
                  .order("category_order ASC NULLS LAST, attribute_order ASC NULLS LAST").to_a

    product_types.each do |product_type|
      product_attributes = attributes.select { |a| a.product_type_ids.empty? || a.product_type_ids.include?(product_type.id)}
      result_hash[product_type.name] = product_attributes.group_by { |attr| attr.category.try(:name) || "General"}
    end
    result_hash
  end

  # Formats keys from DynamicValueAgeBand.age_band_keys into human readable form
  def display_for_age_band(sym)
    r = sym.to_s.split("_")
    if(r[2] == "plus")
      "#{r[1]}+"
    else
      "#{r[1]} - #{r[2]}"
    end
  end

  def new_dynamic_attribute
    d = DynamicAttribute.last.try(:dup) || DynamicAttribute.new
    d.display_name = ""
    d
  end
end
