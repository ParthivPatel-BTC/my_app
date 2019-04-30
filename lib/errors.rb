module Errors
  class KustomerErrors < StandardError
    attr_accessor :errors

    def initialize(msg, errors = {})
      super(msg)
      @errors = errors
    end
  end
end