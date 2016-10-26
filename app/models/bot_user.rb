class BotUser < ActiveRecord::Base
  belongs_to :bot_instance
  has_many :events

  validates_presence_of :uid, :membership_type, :bot_instance_id, :provider
  validates_uniqueness_of :uid, scope: :bot_instance_id
  validates_inclusion_of  :provider, in: %w(slack kik facebook telegram)

  scope :user_attributes_eq, ->(field, value) do
    where(
      "bot_users.user_attributes->>:field = :value",
      field: field,
      value: value
    )
  end

  scope :user_attributes_cont, ->(field, value) do
    where(
      "bot_users.user_attributes->>:field ILIKE :value",
      field: field,
      value: "%#{value}%"
    )
  end

  scope :interaction_count_eq, ->(count)do
    where("bot_interaction_count = ?", count)
  end

  scope :interaction_count_lt, ->(count)do
    where("bot_interaction_count < ?", count)
  end

  scope :interaction_count_gt, ->(count)do
    where("bot_interaction_count > ?", count)
  end

  scope :interaction_count_betw, ->(min, max)do
    where('bot_interaction_count BETWEEN ? AND ?', min, max)
  end

  scope :interacted_at_betw, ->(query, min, max) do
    where('last_interacted_with_bot_at BETWEEN ? AND ?', min, max).
    order("last_interacted_with_bot_at DESC NULLS LAST")
  end

  scope :dashboard_betw, ->(query, min, max) do
    where(id: query.dashboard.events.where("events.created_at" => min..max).select(:bot_user_id))
  end

  scope :dashboard_gt, ->(query, days_ago) do
    where(id: query.dashboard.events.where("events.created_at < ?", days_ago).select(:bot_user_id))
  end

  scope :dashboard_lt, ->(query, days_ago) do
    where(id: query.dashboard.events.where("events.created_at > ?", days_ago).select(:bot_user_id))
  end

  scope :interacted_at_lt, ->(query, days_ago) do
    where('last_interacted_with_bot_at > ?', days_ago).
    order("last_interacted_with_bot_at DESC NULLS LAST")
  end

  scope :interacted_at_gt, ->(query, days_ago) do
    where('last_interacted_with_bot_at < ?', days_ago).
    order("last_interacted_with_bot_at DESC NULLS LAST")
  end

  scope :user_signed_up_gt, ->(query, days_ago) do
    where('created_at < ?', days_ago)
  end

  scope :user_signed_up_lt, ->(query, days_ago) do
    where('created_at > ?', days_ago)
  end

  scope :user_signed_up_betw, ->(query, min, max) do
    where(created_at: min..max)
  end

  store_accessor :user_attributes, :nickname, :email, :full_name, :first_name, :last_name, :gender, :timezone

  def self.with_bot_instances(instances, bot, start_time, end_time)
    created_at = bot.provider == 'slack' ? "bot_instances.created_at" : "bot_users.created_at"

    where(bot_instance_id: instances.select(:id)).joins(:bot_instance).
      where(created_at => start_time..end_time)
  end

  def self.with_messages_to_bot(associated_bot_instances_ids)
    select("bot_users.*, COALESCE(e.cnt, 0) AS events_count, e.c_at AS last_event_at").
    joins("LEFT JOIN (SELECT bot_user_id, COUNT(*) AS cnt, MAX(events.created_at) AS c_at FROM events WHERE events.event_type = 'message' AND events.is_for_bot = 't' GROUP by bot_user_id) e ON e.bot_user_id = bot_users.id").
    where("bot_users.bot_instance_id IN (?)", associated_bot_instances_ids).
    order("last_event_at DESC NULLS LAST")
  end

  def self.with_messages_from_bot(associated_bot_instances_ids)
    select("bot_users.*, COALESCE(e.cnt, 0) AS events_count, e.c_at AS last_event_at").
    joins("LEFT JOIN (SELECT bot_user_id, COUNT(*) AS cnt, MAX(events.created_at) AS c_at FROM events WHERE events.event_type = 'message' AND events.is_from_bot = 't' GROUP by bot_user_id) e ON e.bot_user_id = bot_users.id").
    where("bot_users.bot_instance_id IN (?)", associated_bot_instances_ids).
    order("last_event_at DESC NULLS LAST")
  end

  def self.with_messaging_postbacks(associated_bot_instances_ids)
    select("bot_users.*, COALESCE(e.cnt, 0) AS events_count, e.c_at AS last_event_at").
    joins("LEFT JOIN (SELECT bot_user_id, COUNT(*) AS cnt, MAX(events.created_at) AS c_at FROM events WHERE events.event_type = 'messaging_postbacks' GROUP by bot_user_id) e ON e.bot_user_id = bot_users.id").
    where("bot_users.bot_instance_id IN (?)", associated_bot_instances_ids).
    order("last_event_at DESC NULLS LAST")
  end

  def self.with_message_subtype(associated_bot_instance_ids, type, provider)
    case provider
    when 'facebook'
      select("bot_users.*, COALESCE(e.cnt, 0) AS events_count, e.c_at AS last_event_at").
      joins("LEFT JOIN (SELECT bot_user_id, COUNT(*) AS cnt, MAX(events.created_at) AS c_at FROM events WHERE events.event_type = 'message' " +
            "AND (event_attributes->>'attachments')::text IS NOT NULL AND (event_attributes->'attachments'->0->>'type')::text = '#{type}' " +
            "GROUP by bot_user_id) e ON e.bot_user_id = bot_users.id").
      where("bot_users.bot_instance_id IN (?)", associated_bot_instance_ids).
      order("last_event_at DESC NULLS LAST")
    when 'kik'
      select("bot_users.*, COALESCE(e.cnt, 0) AS events_count, e.c_at AS last_event_at").
      joins("LEFT JOIN (SELECT bot_user_id, COUNT(*) AS cnt, MAX(events.created_at) AS c_at FROM events WHERE events.event_type = 'message' " +
            "AND (event_attributes->>'sub_type')::text IS NOT NULL AND (event_attributes->>'sub_type')::text = '#{type}' " +
            "GROUP by bot_user_id) e ON e.bot_user_id = bot_users.id").
      where("bot_users.bot_instance_id IN (?)", associated_bot_instance_ids).
      order("last_event_at DESC NULLS LAST")
    end
  end

  def self.with_events(associated_bot_user_ids, event_ids)
    events_condition = sanitize_sql_hash_for_conditions("events.id" => event_ids)

    select("bot_users.*, COALESCE(e.cnt, 0) AS events_count, e.c_at AS last_event_at").
    joins("LEFT JOIN (SELECT bot_user_id, COUNT(*) AS cnt, MAX(events.created_at) AS c_at FROM events WHERE #{events_condition} GROUP by bot_user_id) e ON e.bot_user_id = bot_users.id").
    where("bot_users.id IN (?)", associated_bot_user_ids).
    order("last_event_at DESC NULLS LAST")
  end

  def self.by_cohort(bot, start_time: 8.weeks.ago, group_by: 'week')
    start_time = start_time.beginning_of_week
    end_time = Time.current.end_of_week
    # number of weeks
    periods = ((end_time.to_i - start_time.to_i).to_f / (24 * 60 * 60 * 7)).ceil

    bot_instance_ids = bot.instances.pluck("bot_instances.id")
    first_cohort = sanitize_sql_hash_for_conditions("esub.created_at" => start_time..start_time.end_of_week)
    users_condition = sanitize_sql_hash_for_conditions("bot_users.created_at" => start_time..start_time.end_of_week)
    bot_condition = sanitize_sql_hash_for_conditions("esub.bot_instance_id" => bot_instance_ids)

    counts = []
    periods.times { |i| counts << "COUNT(DISTINCT e#{i+1}.bot_user_id)" }

    sql = ["SELECT"]
    sql << counts.join(",")
    sql << "FROM"
    sql << """
    (
      SELECT * FROM events esub
      INNER JOIN bot_users ON bot_users.id = esub.bot_user_id
      WHERE #{first_cohort}
      AND #{bot_condition}
      AND #{users_condition}
      AND esub.is_for_bot = 't'
    ) e1
    """

    (2..periods).each do |i|
      next_cohort = sanitize_sql_hash_for_conditions("esub.created_at" => (start_time + (i-1).week)..(start_time + (i-1).week).end_of_week)
      sql << """
        LEFT OUTER JOIN LATERAL (
         SELECT * FROM events esub
         WHERE esub.bot_user_id = e#{i-1}.bot_user_id
         AND #{next_cohort}
         AND #{bot_condition}
         AND esub.is_for_bot = 't'
         LIMIT 1
        ) e#{i}
        ON true
      """
    end

    records = Event.connection.execute(sql.join("\n"))
    records.values.first.map(&:to_i)
  end
end
