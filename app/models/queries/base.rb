module Queries
  class Base
    DASHBOARDS = [
      'user-actions',
      'image-uploaded',
      'video-uploaded',
      'audio-uploaded',
      'file-uploaded',
      'location-sent',
      'link-uploaded',
      'scanned-data',
      'sticker-uploaded',
      'friend-picker-chosen',
      'custom'
    ]

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
      field.in?(['interacted_at', 'user_created_at']) || field.match(/\Adashboard:[0-9a-f]+\Z/)
    end

    def fields(bot)
      dashboard_hash = bot.dashboards.where(dashboard_type: DASHBOARDS, enabled: true).
                        inject({}) { |hash, d| hash["dashboard:#{d.uid}"] = d.name; hash }

      self.class::FIELDS.merge(dashboard_hash)
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
