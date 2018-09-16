module SerializerSpecHelper
  def serialize(obj, opts={})
    serializer_class = opts.delete(:serializer_class) || "#{obj.class.name}Serializer".constantize
    serializer = serializer_class.send(:new, obj, {root: false})
    JSON.parse(serializer.to_json)
  end
end
