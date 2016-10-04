RSpec.describe EditNotificationController do
  let!(:user) { create :user }
  let!(:bot)  { create :bot }
  let!(:bc)   { create :bot_collaborator, bot: bot, user: user }

  let!(:query_set)    { create(:query_set, :with_slack_queries, bot: bot) }
  let!(:notification) { create(:notification, bot: bot, query_set: query_set, scheduled_at: dt_fmt(10.days.from_now))}

  before { sign_in user }

  def dt_fmt(dt)
    dt.strftime('%b %d, %Y %l:%M %p')
  end

  shared_examples 'inaccessible if already sent' do
    context 'sent immediately' do
      before { notification.update(scheduled_at: nil) }

      it 'raises error' do
        do_request

        expect(response.status).to eq 404
      end
    end

    context 'scheduled and sent' do
      before { notification.update(scheduled_at: dt_fmt(5.days.ago)) }

      it 'raises error' do
        do_request

        expect(response.status).to eq 404
      end
    end
  end

  describe '#step_1' do
    def do_request
      get :step_1, { bot_id: bot.to_param, id: notification.to_param }.merge(params)
    end

    context 'without params' do
      let(:params) { {} }

      it_behaves_like 'inaccessible if already sent'

      it 'success' do
        do_request

        expect(response).to be_success

        # Assigns will be deprecated in Rails 5..
        # But this is the easiest to check that the existing QuerySet was loaded
        expect(assigns(:query_set).to_form_params).to eq query_set.to_form_params
      end
    end

    context 'with params' do
      let(:params) { { query_set: queries_attributes } }
      let(:queries_attributes) { { queries_attributes: { '0' => { provider: 'slack', field: 'nickname', method: 'equals_to', value: 'john' } } } }

      it 'success' do
        do_request

        expect(response).to be_success

        # Assigns will be deprecated in Rails 5..
        # But this is the easiest to check that the existing QuerySet was loaded
        expect(assigns(:query_set).to_form_params.dig(:query_set, :queries_attributes)).to eq queries_attributes[:queries_attributes]
      end

      it 'sets session' do
        do_request

        expect(response).to be_success
        expect(session[:edit_notification_query_set]).to match({query_set: hash_including})
        expect(session[:edit_notification_query_set][:query_set][:queries_attributes].values.first).
          to match(hash_including(value: 'john'))
      end
    end

    context 'reset' do
      let(:params) { { reset: :reset } }

      before { session[:edit_notification_query_set] = double('ok') }

      it 'resets session to default query' do
        do_request

        expect(session[:edit_notification_query_set]).to match({query_set: hash_including})
      end
    end
  end

  describe '#step_2' do
    let(:params) { {} }

    def do_request
      get :step_2, { bot_id: bot.to_param, id: notification.to_param }.merge(params)
    end

    it_behaves_like 'inaccessible if already sent'

    context 'valid step 1' do
      before { session[:edit_notification_query_set] = double(:ok) }
      after  { session[:edit_notification_query_set] = nil }

      it 'works' do
        do_request

        expect(response).to be_success
      end
    end

    context 'invalid step 1' do
      before { session[:edit_notification_query_set] = nil }

      it 'redirects' do
        do_request

        expect(response).to redirect_to step_1_bot_edit_notification_path(bot, notification)
      end
    end
  end

  describe '#step_3' do
    let(:params) { { notification: { content: content } } }

    def do_request
      get :step_3, { bot_id: bot.to_param, id: notification.to_param }.merge(params)
    end

    it_behaves_like 'inaccessible if already sent' do
      let(:content) { 'Ok' }
    end

    context 'valid step 2' do
      let(:content) { 'Hello World'}

      it 'works' do
        do_request

        expect(response).to be_success
      end
    end

    context 'invalid step 2' do
      let(:content) { ''}

      it 'redirects back to step 2' do
        do_request

        expect(response).to redirect_to step_2_bot_edit_notification_path(bot, notification, params.slice(:notification))
      end
    end
  end

  describe '#update' do
    let(:session_query_set)    { { query_set: query_set_attributes.merge(queries_attributes) } }
    let(:query_set_attributes) { { bot_id: bot.id, instances_scope: 'enabled', time_zone: user.timezone } }
    let(:queries_attributes)   { { queries_attributes: { '0' => { provider: 'slack', field: 'email', method: 'contains', value: 'newton' } } } }

    def do_request
      patch :update, { bot_id: bot.to_param, id: notification.to_param }.merge(params)
    end

    before { session[:edit_notification_query_set] = session_query_set }

    context 'success' do
      before do
        allow(SendNotificationJob).to    receive(:perform_async)
        allow(EnqueueNotificationJob).to receive(:perform_async)
      end

      context 'send now' do
        let(:params) { { notification: { content: 'New Hello World', scheduled_at: '', recurring: 'false' } } }

        it 'queues up a job' do
          do_request

          expect(SendNotificationJob).to have_received(:perform_async).with(Notification.last.id)
        end

        it 'saves and redirects' do
          expect { do_request }.
            to change(Notification, :count).by(0).
            and change(QuerySet, :count).by(0)

          expect(notification.reload.content).to match 'New'

          expect(notification.reload.query_set.queries.first.field).to  eq 'email'
          expect(notification.reload.query_set.queries.first.method).to eq 'contains'
          expect(notification.reload.query_set.queries.first.value).to  eq 'newton'

          expect(response).to redirect_to bot_notification_path(bot, Notification.last)
        end

        it 'clears the session' do
          do_request

          expect(session[:edit_notification_query_set]).to be_nil
        end
      end

      context 'send at a specific time' do
        let(:params) do
          { notification:
              {
                content: 'New Hello World',
                scheduled_at: scheduled_at,
                recurring: 'false'
              }
          }
        end
        let(:scheduled_at) { dt_fmt 5.days.from_now }

        it 'queues up a job' do
          do_request

          expect(EnqueueNotificationJob).to have_received(:perform_async)
        end

        it 'saves and redirects' do
          expect { do_request }.
            to change(Notification, :count).by(0).
            and change(QuerySet, :count).by(0)

          expect(notification.reload.content).to match 'New'
          expect(notification.reload.scheduled_at).to eq scheduled_at

          expect(notification.reload.query_set.queries.first.field).to  eq 'email'
          expect(notification.reload.query_set.queries.first.method).to eq 'contains'
          expect(notification.reload.query_set.queries.first.value).to  eq 'newton'

          expect(response).to redirect_to bot_notifications_path(bot)
        end

        it 'clears the session' do
          do_request

          expect(session[:edit_notification_query_set]).to be_nil
        end
      end

      context 'send at a specific time (recurring)' do
        let(:params) do
          { notification:
              {
                content: 'New Hello World',
                scheduled_at: scheduled_at,
                recurring: 'true'
              }
          }
        end
        let(:scheduled_at) { '9:00am' }

        it 'queues up a job' do
          do_request

          expect(EnqueueNotificationJob).to have_received(:perform_async)
        end

        it 'saves and redirects' do
          expect { do_request }.
            to change(Notification, :count).by(0).
            and change(QuerySet, :count).by(0)

          expect(notification.reload.content).to match 'New'
          expect(notification.reload.scheduled_at).to eq scheduled_at

          expect(notification.reload.query_set.queries.first.field).to  eq 'email'
          expect(notification.reload.query_set.queries.first.method).to eq 'contains'
          expect(notification.reload.query_set.queries.first.value).to  eq 'newton'

          expect(response).to redirect_to bot_notifications_path(bot)
        end

        it 'clears the session' do
          do_request

          expect(session[:edit_notification_query_set]).to be_nil
        end
      end
    end

    context 'failure' do
      let(:params) { { notification: { content: '' } } }

      it_behaves_like 'inaccessible if already sent'

      it 'does not queue up a job' do
        do_request

        expect(response).to redirect_to step_3_bot_edit_notification_path(bot, notification, params.slice(:notification))
      end

      context 'invalid recurring scheduled_at' do
        let(:params) { { notification: { content: 'abc', scheduled_at: '13:00', recurring: true } } }

        it 'does not queue up a job' do
          do_request

          expect(response).to redirect_to step_3_bot_edit_notification_path(bot, notification, params.slice(:notification))
        end
      end
    end
  end
end
