require "core_ext/hash"
require "date"
require "time"

class HashMapper
  SEPARATOR = "."

  Types = [String, Integer, Float, Time, Date, DateTime]

  def self.parse(hash = {}, &block)
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

    def self.map(input, output, type_or_symbol = nil, &block)
      key = @@path + [input]
      key = key.join(SEPARATOR).to_s

      if @hash.has_key?(key)
        hash_value = type_or_symbol.nil? ? @hash[key] : typecast(@hash[key], type_or_symbol)

        condition = true
        if block_given?
          condition = yield hash_value
        end

        @parsed[output.to_s] = hash_value if condition
      end
    end

    def self.typecast(value, type_or_symbol)
      if type_or_symbol.is_a?(Symbol)
        value.send(type_or_symbol)
      elsif type_or_symbol.is_a?(Class) && Types.include?(type_or_symbol)
        case type_or_symbol.to_s
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
end
