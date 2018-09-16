# == Schema Information
#
# Table name: products
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  selectors       :text
#  product_type_id :integer
#  contributory    :boolean          default(TRUE), not null
#  document_id     :integer
#

require 'rails_helper'

describe Product do
  let(:dynamic_attributes) { create_list :dynamic_attribute, 3 }
  let(:product_type) { create(:product_type) {|pt| pt.dynamic_attributes = dynamic_attributes} }
  let(:project) { create :project }
  let(:proposal) { create :document, project: project }
  let(:product) { create :product, document: proposal, product_type: product_type }

  describe '#correspondent_inforce_product' do
    let!(:policy) { create :document, :policy, project: project }
    let!(:inforce_product) { create :product, document: policy, product_type: product_type }

    it 'returns correspondent inforce product' do
      expect(product.correspondent_inforce_product).to eq inforce_product
    end
  end

  describe '#match_product' do
    let(:policy) { create :document, :policy, project: project }
    let(:inforce_product) { create :product, document: policy, product_type: product_type }
    let(:inforce_classes) {[
      create(:product_class, class_number: 1, product: inforce_product),
      create(:product_class, class_number: 2, product: inforce_product),
      create(:product_class, class_number: 3, product: inforce_product)
    ]}
    let(:product_classes) {[
      create(:product_class, class_number: 1, product: product),
      create(:product_class, class_number: 2, product: product)
    ]}

    it 'does match correctly' do
      inforce_classes.each {|c| c.dynamic_values.each_with_index {|dv, i| dv.update(value: i)}}

      product.match_product(inforce_product)
      expect(product.product_classes.count).to eq 3
      expect(product.product_classes.first.dynamic_values.pluck(:value).sort).to eq %w(0 1 2)
    end
  end
end
