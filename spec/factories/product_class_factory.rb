# == Schema Information
#
# Table name: product_classes
#
#  id           :integer          not null, primary key
#  product_id   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  description  :string
#  selectors    :text
#  class_number :integer
#

FactoryGirl.define do
  factory :product_class do
    product
    sequence(:class_number)

    trait(:with_values) do
      dynamic_values { build_list :dynamic_value, 1 }
    end

    factory :product_class_with_values, traits: [:with_values]
  end
end
