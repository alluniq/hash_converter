class Hash
  @@namespace = []
  def namespace_flatten(separator = ".")
    h = {}
    self.each do |key, value|
      k = key.to_s
      if value.is_a?(Hash)
        @@namespace << k
        h.merge! value.namespace_flatten(separator)
        @@namespace.pop
      else
        key = @@namespace + [k]
        h[key.join(separator)] = value
      end
    end
    h
  end
end
