# == Schema Information
#
# Table name: orderings
#
#  id              :integer          not null, primary key
#  parent_type     :string
#  parent_id       :integer
#  order_index     :integer          default(0)
#  carrier_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  product_type_id :integer
#

FactoryGirl.define do
  factory :ordering do
    association :parent, factory: :dynamic_attribute
    order_index 1
  end

end
