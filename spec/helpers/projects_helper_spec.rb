require 'rails_helper'

RSpec.describe ProjectsHelper, :type => :helper do

  describe "#worksheet_safe_name" do
    it "does not modify the input string" do
      x = "Test / ][?*]"
      result = helper.worksheet_safe_name(x)
      expect(result).to_not eq(x)
      expect(x).to eq("Test / ][?*]")
    end

    it "replaces '/' with 'and'" do
      expect(worksheet_safe_name("Test / Test")).to eq("Test and Test")
    end

    it "replaces illegal characters with nothing" do
      expect(worksheet_safe_name("\?*[or]")).to eq("or")
    end
  end


  describe '#format_value' do
    it 'returns percent value if it has percent format option' do
      expect(helper.format_value(:percent, '44%')).to eql(0.44)
      expect(helper.format_value(:percent, '')).to be_nil
    end

    it 'returns currency value if it has currency export option' do
      expect(helper.format_value(:currency, '$44,000')).to eql(44000.0)
      expect(helper.format_value(:currency, '')).to be_nil
    end
  end
end
