module Queries
  class Null
    FIELDS  = {}

    STRING_METHODS   = {}
    NUMBER_METHODS   = {}
    DATETIME_METHODS = {}
    AGO_METHODS      = {}

    def is_string_query?(field)
      false
    end

    def is_number_query?(field)
      false
    end

    def is_datetime_query?(field)
      false
    end

    def fields(bot)
      FIELDS
    end

    def string_methods
      STRING_METHODS
    end

    def number_methods
      NUMBER_METHODS
    end

    def datetime_methods
      DATETIME_METHODS
    end
  end
end
