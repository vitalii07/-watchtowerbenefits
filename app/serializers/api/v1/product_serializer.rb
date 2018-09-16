module Api::V1
  class ProductSerializer < ActiveModel::Serializer
    attributes :id, :product_type_id, :product_type_name, :contributory, :document_id, :carrier

    has_many :product_classes, root: :classes, each_serializer: ::Api::V1::ProductClassSerializer
    has_one :carrier, serializer: ::Api::V1::CarrierSerializer

    def product_type_name
      object.product_type.name
    end
  end
end
