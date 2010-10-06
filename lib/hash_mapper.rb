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

    def self.map(input, output, &block)
      key = @@path + [input]
      key = key.join(SEPARATOR).to_s

      if @hash.has_key?(key)
        hash_value = @hash[key]

        condition = true
        if block_given?
          condition = yield hash_value
        end

        @parsed[output.to_s] = hash_value if condition
      end
    end
end
