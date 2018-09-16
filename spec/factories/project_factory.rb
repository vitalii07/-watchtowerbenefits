# == Schema Information
#
# Table name: projects
#
#  id             :integer          not null, primary key
#  name           :string
#  employer_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#  is_archived    :boolean          default(FALSE)
#  effective_date :date
#  view_options   :json
#

FactoryGirl.define do
  factory :project do
    user
    employer
    effective_date 1.month.from_now.to_date
  end
end
