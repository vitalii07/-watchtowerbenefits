class ProjectSerializer < ActiveModel::Serializer
  attributes :created_at, :id, :view_options, :rollup_data, :rollup_classes, :contextual_contents

  has_many :proposals, :policies, :project_product_types

  def rollup_classes
    rollup_classes?
  end

  def rollup_data
    object.class_rollup_data if rollup_classes?
  end

  def contextual_contents
    object.contextual_contents.group_by(&:associatable_id)
  end

  private

  def rollup_classes?
    true #serialization_options[:rollup_classes]
  end
end
