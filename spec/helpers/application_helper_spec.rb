require 'rails_helper'

RSpec.describe ApplicationHelper, :type => :helper do
  describe "attributes_for_carrier" do
    before(:each) do
      @carrier = create(:carrier)
    end

    it "should sort attributes using carrier override" do
      c1 = create(:category)
      p = create(:product_type)
      a1 = create(:dynamic_attribute, parent_class: "Product", category: c1, attribute_order: 3, product_types: [p])
      a2 = create(:dynamic_attribute, parent_class: "Product", category: c1, attribute_order: 2, product_types: [p])
      a3 = create(:dynamic_attribute, parent_class: "Product", category: c1, attribute_order: 5, product_types: [p])
      Ordering.create(parent: a3, carrier: @carrier, product_type: p, order_index: 1)
      returned_attributes = helper.attributes_for_carrier(create(:product), @carrier, p)
      expect(returned_attributes).to eq([a3, a2, a1])
    end
  end

  describe "#display_for_age_band" do
    it "displays the format n - n" do
      expect(helper.display_for_age_band(:age_20_24)).to eq("20 - 24")
    end

    it "displays the format n+" do
      expect(helper.display_for_age_band(:age_20_plus)).to eq("20+")
    end
  end
end
