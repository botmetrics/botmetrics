module Queries
  class Base
    STRING_METHODS = {
      'equals_to' => 'Equals To',
      'contains'  => 'Contains'
    }

    NUMBER_METHODS = {
      'equals_to'    => 'Equals To',
      'lesser_than'  => 'Lesser Than',
      'greater_than' => 'Greater Than',
      'between'      => 'Between'
    }

    DATETIME_METHODS = {
      'between'   => 'Between',
      'lesser_than'  => 'Less Than',
      'greater_than' => 'More Than'
    }

    def is_number_query?(field)
      field.in?(['interaction_count'])
    end

    def is_datetime_query?(field)
      field.in?(['interacted_at', 'user_created_at'])
    end

    def fields(bot)
      self.class::FIELDS
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
