require 'rails_helper'

describe ProjectSerializer, type: :serializer do
  describe 'attributes' do
    let!(:policies) { create_list :document, 4, :policy, project: project }
    let!(:proposals) { create_list :document, 2, project: project }
    let!(:proposal) { create :document, project: project, state: :finalized }
    let(:project) { create :project }
    let!(:product_type1) { create :product_type, dynamic_attributes: [dynamic_attribute1, dynamic_attribute2] }
    let!(:product_type2) { create :product_type, dynamic_attributes: [dynamic_attribute3] }
    let!(:product1) { create :product, product_type: product_type1, document: proposal }
    let!(:product2) { create :product, product_type: product_type2, document: proposal }
    let!(:product_class1) { a = build :product_class, product: product1; a.do_not_create_values = true; a.save; a }
    let!(:product_class2) { a = build :product_class, product: product1; a.do_not_create_values = true; a.save; a }
    let!(:product_class3) { a = build :product_class, product: product1; a.do_not_create_values = true; a.save; a }
    let!(:product_class4) { a = build :product_class, product: product2; a.do_not_create_values = true; a.save; a }
    let!(:product_class5) { a = build :product_class, product: product2; a.do_not_create_values = true; a.save; a }
    let!(:dynamic_value1) { create :dynamic_value, parent: product_class1, value: '1', dynamic_attribute: dynamic_attribute1 }
    let!(:dynamic_value2) { create :dynamic_value, parent: product_class2, value: '1', dynamic_attribute: dynamic_attribute1 }
    let!(:dynamic_value3) { create :dynamic_value, parent: product_class3, value: '1', dynamic_attribute: dynamic_attribute1 }
    let!(:dynamic_value4) { create :dynamic_value, parent: product_class1, value: '2', dynamic_attribute: dynamic_attribute2 }
    let!(:dynamic_value5) { create :dynamic_value, parent: product_class2, value: '2', dynamic_attribute: dynamic_attribute2 }
    let!(:dynamic_value6) { create :dynamic_value, parent: product_class1, value: '3', dynamic_attribute: dynamic_attribute1 }
    let!(:dynamic_value7) { create :dynamic_value, parent: product_class2, value: '3', dynamic_attribute: dynamic_attribute1 }
    let!(:dynamic_value8) { create :dynamic_value, parent: product_class3, value: '3', dynamic_attribute: dynamic_attribute1 }
    let!(:project_product_type1) { create :project_product_type, project: project, product_type: product_type1 }
    let!(:project_product_type2) { create :project_product_type, project: project, product_type: product_type2 }
    let!(:dynamic_attribute1) { create :dynamic_attribute, category: category }
    let!(:dynamic_attribute2) { create :dynamic_attribute, category: category }
    let!(:dynamic_attribute3) { create :dynamic_attribute, category: category }
    let!(:category) { create :category }
    let(:attributes) {
      ['contextual_contents', 'created_at', 'id', 'view_options', 'rollup_data', 'rollup_classes', 'proposals',
       'policies', 'project_product_types']
    }

    it 'return correct attributes' do
      data = serialize(project, serializer_class: described_class)
      expect(data.keys).to match_array attributes
      expect(data['project_product_types'].size).to eq 2
      expect(data['proposals'].size).to eq 3
      expect(data['policies'].size).to eq 4
      expect(data['rollup_classes']).to eq true
      expect(data['rollup_data'].keys).to match_array ['1', '2']
    end
  end
end
