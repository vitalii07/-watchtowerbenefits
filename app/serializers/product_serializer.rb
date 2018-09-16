class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :product_id, :product_position, :is_contributory
  has_many :product_classes

  def name
    object.product_type.name
  end

  def product_id
    object.product_type.id
  end

  def product_position
    object.product_type.broker_app_position
  end

  def is_contributory
    object.contributory
  end
end
