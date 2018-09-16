# == Schema Information
#
# Table name: dynamic_values
#
#  id                    :integer          not null, primary key
#  dynamic_attribute_id  :integer
#  parent_id             :integer
#  parent_type           :string
#  value                 :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  comparison_flag       :integer          default(0)
#  selector              :string
#  is_atp_rate           :boolean          default(FALSE), not null
#  annotations_in_source :json
#  volume                :integer
#  label                 :string
#  rate_basis            :integer
#  compound              :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :dynamic_value do
    association :parent, factory: :product_class
    sequence(:value) {|n| "some_value_#{n}" }
    dynamic_attribute

    trait(:product_parent) do
      association :parent, factory: :product
    end

    trait(:project_product_type_parent) do
      association :parent, factory: :project_product_type
    end

    trait(:rate_guarantee) do
      association :dynamic_attribute, factory: [:dynamic_attribute, :rate_guarantee]
    end
  end
end
