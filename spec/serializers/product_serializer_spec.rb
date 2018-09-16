require 'rails_helper'

describe ProductSerializer, type: :serializer do
  describe 'attributes' do
    let(:product_type) { create :product_type, name: 'name', broker_app_position: 5 }
    let(:product) { create :product, product_type: product_type, contributory: true }
    let!(:product_classes) { create_list :product_class, 3, product: product }
    let(:attributes) { ['id', 'name', 'product_id', 'product_position', 'is_contributory', 'product_classes'] }

    it 'return correct attributes' do
      data = serialize(product, serializer_class: described_class)
      expect(data.keys).to match_array attributes
      expect(data['product_classes'].size).to eq 3
      expect(data['name']).to eq 'name'
      expect(data['product_id']).to eq product_type.id
      expect(data['product_position']).to eq 5
      expect(data['is_contributory']).to eq true
    end
  end
end
