# == Schema Information
#
# Table name: sources
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  file_file_name     :string
#  file_content_type  :string
#  file_file_size     :integer
#  file_updated_at    :datetime
#  raw_html           :text
#  document_id        :integer
#  nota_configuration :json
#  name               :string
#

FactoryGirl.define do
  factory :source do
    document
  end
end
