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
end
