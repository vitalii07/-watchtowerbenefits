# == Schema Information
#
# Table name: products
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  selectors       :text
#  product_type_id :integer
#  contributory    :boolean          default(TRUE), not null
#  document_id     :integer
#

FactoryGirl.define do
  factory :product do
    document
    product_type
    contributory false

    trait(:with_classes) do
      product_classes { build_list :product_class_with_values, 1 }
    end

    factory :product_with_classes, traits: [:with_classes]
  end
end
