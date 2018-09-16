# == Schema Information
#
# Table name: categories
#
#  id             :integer          not null, primary key
#  name           :string
#  category_order :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :category do
    name "MyString"
    sequence :category_order do |n|
      n + 1
    end
  end

end
