require "core_ext/hash"
require "pp"
class HashMapper
  SEPARATOR = "."

  def self.parse(hash, &block)
    @hash = hash.namespace_flatten(SEPARATOR)
    @parsed = {}
    @@path = []

    instance_eval(&block)

    @parsed
  end

  private

    def self.path(path, &block)
      @@path.push(path)
      instance_eval(&block)
      @@path.pop
    end

    def self.map(input, output)
      key = @@path + [input]
      @parsed[output.to_s] = @hash[key.join(SEPARATOR).to_s]
    end
end
