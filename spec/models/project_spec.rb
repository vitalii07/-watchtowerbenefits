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

require 'rails_helper'

describe Project, type: :model do
  let(:project) { create(:project) }
  let(:proposal) { create(:document, project: project) }

  describe '#mark_as_sold' do
    it 'returns true when a proposal is updated as sold' do
      expect(proposal).to receive(:update) { true }

      expect(project.mark_as_sold(proposal)).to eql(true)
    end

    it 'returns false if the proposal is not updated as sold' do
      expect(proposal).to receive(:update) { false }

      expect(project.mark_as_sold(proposal)).to eql(false)
    end

    it 'returns false if a proposal is already marked as sold' do
      project.mark_as_sold(proposal)

      expect(project.mark_as_sold(proposal)).to eql(false)
    end
  end

  describe '#name' do
    it 'updates employer name' do
      project.name = 'Test Project'
      expect(project.employer.name).to eq 'Test Project'
    end
  end

  describe '#documents_for_export' do
    let!(:documents) { create_list :document, 5, :finalized, project: project }
    let!(:policy) { create :document, :policy, :finalized, project: project }

    it 'sorts documents like: first policy, then other documents by id' do
      expect(project.documents_for_export).to eq [policy, documents.sort_by(&:id)].flatten
    end
  end
end
