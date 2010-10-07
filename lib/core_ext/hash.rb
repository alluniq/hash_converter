class Hash
  @@namespace = []

  def namespace_flatten(separator = ".")
    hash = {}
    self.each do |key, value|
      key = key.to_s
      if value.is_a?(Hash)
        @@namespace << key
        hash.merge! value.namespace_flatten(separator)
        @@namespace.pop
      else
        key = @@namespace + [key]
        hash[key.join(separator)] = value
      end
    end
    hash
  end

  def namespace_unflatten(separator = ".")
    hash = {}
    self.each do |key, value|
      hash.merge! self.class.nested_value(value, key.split(separator))
    end
    hash
  end

  def self.nested_value(x, p)
    hash = { p.pop => x }
    p.reverse_each do |element|
        hash = { element => hash }
    end
    hash
  end
end
