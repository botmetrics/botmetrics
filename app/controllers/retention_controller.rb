class RetentionController < ApplicationController
  before_action :authenticate_user!
  before_action :find_bot

  layout 'app'

  def index
    @retention = [
      BotUser.by_cohort(@bot, start_time: 8.weeks.ago),
      BotUser.by_cohort(@bot, start_time: 7.weeks.ago),
      BotUser.by_cohort(@bot, start_time: 6.weeks.ago),
      BotUser.by_cohort(@bot, start_time: 5.weeks.ago),
      BotUser.by_cohort(@bot, start_time: 4.weeks.ago),
      BotUser.by_cohort(@bot, start_time: 3.weeks.ago),
      BotUser.by_cohort(@bot, start_time: 2.weeks.ago),
      BotUser.by_cohort(@bot, start_time: 1.week.ago)
    ]
  end
end
