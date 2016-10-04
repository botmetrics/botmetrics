class QuerySetBuilder
  def initialize(bot: nil, instances_scope: nil , time_zone: nil, default: {}, params: {}, session: {})
    @bot             = bot
    @instances_scope = instances_scope
    @time_zone       = time_zone
    @default         = default
    @params          = ActionController::Parameters.new(params)
    @session         = ActionController::Parameters.new(session)
  end

  def query_set
    QuerySet.new(query_set_params).tap do |qs|
      qs.bot             ||= bot
      qs.instances_scope ||= instances_scope
      qs.time_zone       ||= time_zone
      qs.queries.build(query_params) if qs.queries.blank?
    end
  end

  private
  attr_reader :bot, :instances_scope, :time_zone, :params, :session, :default

  def query_set_params
    case
      when params[:query_set].present?
        secure_query_set_params(params)
      when session[:query_set].present?
        secure_query_set_params(session)
      else
        {}
    end
  end

  def secure_query_set_params(params_hash)
    params_hash.require(:query_set).permit(
      :bot_id, :instances_scope, :time_zone,
      queries_attributes:
        [
          :id, :_destroy,
          :provider, :field, :method, :value,
          :min_value, :max_value,
          :query_set_id
        ]
    )
  end

  def query_params
    default.presence || { provider: bot.provider }
  end
end
