require "date"
require "time"
require "active_support/core_ext/hash/keys"
require "core_ext/hash"

class HashMapper
  SEPARATOR = "."

  Types = [String, Integer, Float, Time, Date, DateTime]

  def self.convert(hash = {}, &block)
    @hash = hash.namespace_flatten(SEPARATOR)
    @converted = {}
    @path = []

    instance_eval(&block)

    @converted.namespace_unflatten.recursive_symbolize_keys!
  end

  private

    def self.path(path, &block)
      @path.push(path)
      instance_eval(&block)
      @path.pop
    end

    def self.map(input, output, type_or_symbol = nil, &block)
      value = self.get(input)
      value = if type_or_symbol.is_a?(Symbol)
        value.send(type_or_symbol)
      elsif type_or_symbol.is_a?(Class)
        typecast(value, type_or_symbol)
      else
        value
      end

      condition = true
      if block_given?
        condition = yield value
      end

      @converted[output.to_s] = value if condition
    end

    def self.typecast(value, type)
      if Types.include?(type)
        case type.to_s
        when "String"
          value.to_s
        when "Integer"
          #from datamapper
          value_to_i = value.to_i
          if value_to_i == 0 && value != '0'
            value_to_s = value.to_s
            begin
              Integer(value_to_s =~ /^(\d+)/ ? $1 : value_to_s)
            rescue ArgumentError
              nil
            end
          else
            value_to_i
          end
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

    def self.get(key)
      key = namespaced_key(key)
      @hash.has_key?(key) ? @hash[key] : nil
    end

    def self.set(key, value)
      @converted[namespaced_key(key)] = value
    end
end
