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

class Product < ActiveRecord::Base
  include DistillableAttributes

  belongs_to :document
  belongs_to :product_type
  has_many :product_classes, dependent: :destroy
  has_many :pc_dynamic_values, through: :product_classes, source: :dynamic_values
  has_many :dynamic_values, as: :parent, dependent: :destroy
  has_one :carrier, through: :document

  serialize :selectors, Hash
  delegate :user, to: :document
  delegate :unit_rate_denominator, to: :product_type

  def correspondent_inforce_product
    policy = document.project.policies.first
    policy.products.where(product_type_id: product_type_id).first
  end

  def match_product(source_product, attribute_id_filter = nil)
    ActiveRecord::Base.transaction do
      source_product.product_classes.each do |inforce_class|
        target_class = product_classes.select {|ic| ic.class_number == inforce_class.class_number }.first
        target_class ||= product_classes.create(class_number: inforce_class.class_number)
        target_class.match_product_class(inforce_class, attribute_id_filter)
      end
    end
  end
end
