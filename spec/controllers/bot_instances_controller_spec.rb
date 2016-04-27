require 'spec_helper'

describe BotInstancesController do
  let!(:user) { create :user }
  let!(:team) { create :team }
  let!(:bot)  { create :bot, team: team }
  let!(:tm1)  { create :team_membership, team: team, user: user }

  describe 'GET new' do
    before { sign_in user }

    def do_request
      get :new, team_id: team.to_param, bot_id: bot.to_param
    end

    it 'should render template :new' do
      do_request
      expect(response).to render_template :new
    end

    it "should set instance variable '@instance'" do
      do_request
      expect(assigns(:instance)).to_not be_nil
    end
  end

  describe 'POST create' do
    let!(:bot_instance_params) { { token: 'token-deadbeef' } }

    before do
      allow(SetupBotJob).to receive(:perform_async)
    end

    shared_examples 'creates and sets up a bot' do
      it 'should create a new bot instance' do
        expect {
          do_request
          bot.reload
        }.to change(bot.instances, :count).by(1)

        instance = bot.instances.last
        expect(instance.token).to eql 'token-deadbeef'
        expect(instance.provider).to eql bot.provider
      end

      it 'should call SetupBotJob' do
        do_request
        expect(SetupBotJob).to have_received(:perform_async)
      end
    end

    context 'format html' do
      before { sign_in user }

      def do_request
        post :create, instance: bot_instance_params, team_id: team.to_param, bot_id: bot.to_param
      end

      it_behaves_like 'creates and sets up a bot'

      it "should redirect back to setting_team_bot_instance_path" do
        do_request
        instance = bot.instances.last
        expect(response).to redirect_to setting_up_team_bot_instance_path(team, bot, instance)
      end
    end

    context 'format json' do
      before { request.headers['Authorization'] = JsonWebToken.encode('user_id' => user.id) }

      def do_request
        post :create, instance: bot_instance_params, team_id: team.to_param, bot_id: bot.to_param, format: :json
      end

      it_behaves_like 'creates and sets up a bot'

      it "should respond with JSON object containing the id of the instance" do
        do_request
        instance = bot.instances.last
        body = JSON.parse(response.body)

        expect(response).to have_http_status :created
        expect(body['id']).to eql instance.id
      end

      context 'when created_at is sent' do
        before do
          Timecop.freeze(Date.today - 3)
          @now = Time.now
          bot_instance_params.merge!(created_timestamp: @now.to_i)
        end

        after  { Timecop.return }

        it_behaves_like 'creates and sets up a bot'

        it 'sets the created_at timestamp to the one specified by the user' do
          do_request
          instance = bot.instances.last
          expect(instance.created_at.to_i).to eql @now.to_i
        end
      end
    end
  end
end
