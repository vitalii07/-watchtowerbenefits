# == Schema Information
#
# Table name: product_types
#
#  id                    :integer          not null, primary key
#  name                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  unit_rate_denominator :float
#  broker_app_position   :integer
#

FactoryGirl.define do
  factory :product_type do
    sequence(:name) {|n| "Name #{n}" }
  end
end
