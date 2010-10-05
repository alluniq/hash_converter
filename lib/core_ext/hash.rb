class Hash
  def namespace_flatten(separator = ".", namespace = "")
    h = {}
    self.each do |key, value|
      k = key.to_s
      unless value.is_a?(Hash)
        h[namespace+k] = value
      else
        namespace += k+separator
        h.merge! value.namespace_flatten(separator, namespace)
      end
    end
    h
  end
end