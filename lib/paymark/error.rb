module Paymark
  class Error < StandardError
    attr_reader :thing
    def initialize(msg="Server Error")
      super(msg)
    end
  end
end
