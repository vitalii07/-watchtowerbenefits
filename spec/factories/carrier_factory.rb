# == Schema Information
#
# Table name: carriers
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  address1   :string
#  address2   :string
#  city       :string
#  state      :string
#  zipcode    :string
#  logo_url   :string
#

FactoryGirl.define do
  factory :carrier do
    name "Generic Insurance Company"
  end

end
