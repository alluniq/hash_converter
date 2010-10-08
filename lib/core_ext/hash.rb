require "active_support/core_ext/hash/deep_merge"

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
      hash.deep_merge! self.class.nested_value(value, key.split(separator))
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

  def recursive_symbolize_keys!
    symbolize_keys!
    values.each { |h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    values.select { |v| v.is_a?(Array) }.flatten.each { |h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    self
  end
end
