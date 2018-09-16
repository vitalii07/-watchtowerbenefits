# == Schema Information
#
# Table name: documents
#
#  id                :integer          not null, primary key
#  sic_code          :string
#  effective_date    :date
#  proposal_duration :integer
#  state             :integer          default(0)
#  selectors         :text
#  document_type     :string
#  project_id        :integer
#  carrier_id        :integer
#  created_at        :datetime
#  updated_at        :datetime
#  is_archived       :boolean          default(FALSE)
#  is_sold           :boolean          default(FALSE)
#  renewal           :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :document do
    project
    carrier
    document_type 'Proposal'

    trait(:policy) do
      document_type 'Policy'
    end

    trait(:complete_graph) do
      products { build_list :product_with_classes, 1 }
    end

    trait(:finalized) do
      state :finalized
    end

    factory :complete_document, traits: [:complete_graph]
  end
end
