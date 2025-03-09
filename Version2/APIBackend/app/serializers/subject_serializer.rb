class SubjectSerializer
  include JSONAPI::Serializer
  attributes :name, :description
end
