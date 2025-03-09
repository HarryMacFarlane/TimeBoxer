class TagSerializer
  include JSONAPI::Serializer
  attributes :tag_name, :description, :color
end
