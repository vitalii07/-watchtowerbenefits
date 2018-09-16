module Api::V1
  class ProjectSerializer < ActiveModel::Serializer
    attributes :id, :effective_date, :view_options

    has_many :documents, each_serializer: ::Api::V1::DocumentSerializer

    def documents
      serialization_options[:in_force] ? object.policies : object.documents
    end
  end
end
