require 'rails_helper'

RSpec.describe NotificationsController do
  let!(:user) { create :user }
  let!(:bot)  { create :bot }
  let!(:bc)   { create :bot_collaborator, bot: bot, user: user }

  before { sign_in user }

  def dt_fmt(dt)
    dt.strftime('%b %d, %Y %l:%M %p')
  end

  describe '#index' do
    def do_request
      get :index, bot_id: bot.uid
    end

    context 'with notifications' do
      before do
        create(:notification, bot: bot)
      end

      it 'works' do
        do_request

        expect(response).to be_success
      end
    end

    context 'with no notifications' do
      it 'works' do
        do_request

        expect(response).to redirect_to step_1_bot_new_notification_index_path(bot)
      end
    end
  end

  describe '#show' do
    let!(:query_set)    { create(:query_set, :with_slack_queries, bot: bot) }
    let!(:notification) { create(:notification, bot: bot, query_set: query_set) }

    def do_request
      get :show, bot_id: bot.uid, id: notification.uid
    end

    it 'works' do
      do_request

      expect(response).to be_success
    end
  end

  describe '#destroy' do
    let!(:notification) { create(:notification, bot: bot, scheduled_at: scheduled_at) }

    def do_request
      delete :destroy, bot_id: bot.uid, id: notification.uid
    end

    context 'sent immediately' do
      let(:scheduled_at) { nil }

      it 'raises error' do
        do_request

        expect(response.status).to eq 404
      end
    end

    context 'scheduled and sent' do
      let(:scheduled_at) { dt_fmt 5.days.ago }

      it 'raises error' do
        do_request

        expect(response.status).to eq 404
      end
    end

    context 'scheduled and not sent' do
      let(:scheduled_at) { dt_fmt 5.days.from_now }

      it 'works' do
        expect {
          do_request
        }.to change(Notification, :count).by(-1)

        expect(response).to redirect_to bot_notifications_path(bot)
      end
    end
  end
end
