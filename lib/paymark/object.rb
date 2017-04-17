module Paymark
  class Object
    def initialize(attributes)
      attributes.each do |key, value|
        send("#{key_map(key)}=", value_map(key, value))
      end
    end

    def self.build(array_or_hash)
      if array_or_hash.is_a? Array
        array_or_hash.map do |hash|
          self.new(hash)
        end
      else
        self.new(array_or_hash)
      end
    end

    def key_map(key)
      snake_case key.to_s
    end

    def value_map(key, value)
      value
    end

    def method_missing(name, *args)
      puts "Missing Property #{name} #{args}"
      # fail unless Rails.env.production?
    end

    def snake_case(string)
      string.gsub(/::/, '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .downcase
    end

  end
end
