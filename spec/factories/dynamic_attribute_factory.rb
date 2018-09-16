# == Schema Information
#
# Table name: dynamic_attributes
#
#  id                   :integer          not null, primary key
#  display_name         :string
#  parent_class         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  value_type           :string
#  required             :boolean          default(FALSE)
#  category_id          :integer
#  attribute_order      :integer
#  is_rate              :boolean          default(FALSE)
#  export_configuration :hstore
#  ignore_attribute     :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :dynamic_attribute do
    required false
    value_type "DynamicValueString"
    sequence(:display_name) {|n| "Name #{n}" }

    trait(:class_description) do
      display_name 'Class Description'
    end

    trait(:rate_guarantee) do
      display_name 'Rate Guarantee'
    end

    trait(:commission) do
      display_name 'Commission'
    end

    trait(:rate) do
      display_name 'Rate'
    end
  end
end
