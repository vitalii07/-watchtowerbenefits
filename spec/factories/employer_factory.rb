# == Schema Information
#
# Table name: employers
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  address1   :string
#  address2   :string
#  city       :string
#  state      :string
#  sic_code   :string
#  user_id    :integer
#

FactoryGirl.define do
  factory :employer do
    name "SunLife"
  end
end
