require "date"
require "time"
require "active_support/core_ext/hash/keys"
require "core_ext/hash"

class HashConverter
  SEPARATOR = "."
  KEY_REGEX = /\{([^}]*)\}/

  Types = [String, Integer, Float, Time, Date, DateTime]

  def self.convert(hash = {}, create_new = true, &block)
    @hash = hash.namespace_flatten(SEPARATOR)

    @converted = create_new ? {} : @hash
    @path = []

    @original_self = Kernel.eval("self", block.binding)
    instance_eval(&block)

    @converted.namespace_unflatten.recursive_symbolize_keys!
  end

  def self.convert!(hash = {}, &block)
    self.convert(hash, false, &block)
  end

  def self.method_missing(method, *args, &block)
    @original_self.send(method, *args, &block)
  end

  private

    def self.path(path, &block)
      @path.push(path)
      instance_eval(&block)
      @path.pop
    end

    def self.map(input, output, type_or_symbol = nil, &block)
      value = if input =~ KEY_REGEX
        input.gsub(KEY_REGEX) { |var| self.get(var.gsub(/\{|\}/,"")) }
      else
        self.get(input)
      end

      value = if type_or_symbol.is_a?(Symbol)
        value.send(type_or_symbol)
      elsif type_or_symbol.is_a?(Class)
        typecast(value, type_or_symbol)
      else
        value
      end

      if block_given?
        value = yield value
      end

      @converted.delete(input.to_sym)
      @converted.delete(input)

      @converted[output.to_s] = value
    end

    def self.typecast(value, type)
      return value if value.nil?

      if Types.include?(type)
        case type.to_s
        when "String"
          value.to_s
        when "Integer"
          value.to_i
        when "Float"
          value.to_f
        when "Time"
          Time.parse(value)
        when "Date"
          Date.parse(value)
        when "DateTime"
          DateTime.parse(value)
        else
          value
        end
      end
    end

    def self.namespaced_key(key)
      (@path + [key]).join(SEPARATOR).to_s
    end

    def self.get(*keys)
      values = []
      keys.each do |key|
        key = namespaced_key(key)
        values <<  @hash[key]
      end
      values.length == 1 ? values.first : values
    end

    def self.set(key, value)
      @converted[key.to_s] = value
    end
end
