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
      key.to_s.snake_case
    end

    def value_map(key, value)
      value
    end

    def method_missing(name, *args)
      puts "Missing Property #{name} #{args}"
      fail unless Rails.env.production?
    end

  end
end
