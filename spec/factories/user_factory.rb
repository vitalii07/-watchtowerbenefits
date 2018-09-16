# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string
#  password_hash   :string
#  password_salt   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#

FactoryGirl.define do
  factory :user do
    password "abc123"
    password_confirmation "abc123"
    sequence :email do |n|
      "user#{n}@example.com"
    end

    trait(:org_admin) do
      after(:create) { |user| user.add_role(:org_admin) }
    end

    trait(:api) do
      email 'api@watchtowerbenefits.com'
      after(:create) { |user| user.add_role(:admin) }
    end
  end
end
