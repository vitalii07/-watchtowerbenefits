# == Schema Information
#
# Table name: project_product_types
#
#  id              :integer          not null, primary key
#  project_id      :integer          not null
#  product_type_id :integer          not null
#  inforce         :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :project_product_type do
    project
    product_type
  end
end
