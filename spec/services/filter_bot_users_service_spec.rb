RSpec.describe FilterBotUsersService do
  describe '#scope' do
    let!(:user)       { create(:user) }
    let!(:bot)        { create(:bot) }
    let!(:instance_1) { create(:bot_instance, :with_attributes, uid: '123', bot: bot, state: 'enabled') }

    let!(:bot_user_1) { create(:bot_user, bot_instance: instance_1, user_attributes: { nickname: 'john', email: 'john@example.com' }, last_interacted_with_bot_at: 3.days.ago) }
    let!(:bot_user_2) { create(:bot_user, bot_instance: instance_1, user_attributes: { nickname: 'sean', email: 'sean@example.com' }) }
    let!(:bot_user_3) { create(:bot_user, bot_instance: instance_1, user_attributes: { nickname: 'mike', email: 'mike@example.com' }) }

    ##### These do not appear - START
    let!(:instance_2) { create(:bot_instance, :with_attributes, uid: '456', bot: bot, state: 'pending') }

    let!(:bot_user_4) { create(:bot_user, bot_instance: instance_2, user_attributes: { nickname: 'johny', email: 'johny@example.com' }) }
    let!(:bot_user_5) { create(:bot_user, bot_instance: instance_2, user_attributes: { nickname: 'seany', email: 'seany@example.com' }) }
    let!(:bot_user_6) { create(:bot_user, bot_instance: instance_2, user_attributes: { nickname: 'mikey', email: 'mikey@example.com' }) }
    ##### These do not appear - END

    let(:query_set) { create(:query_set, bot: bot, instances_scope: :legit, time_zone: user.timezone) }
    let(:service)   { FilterBotUsersService.new(query_set) }

    context 'slack' do
      let(:provider) { 'slack' }

      context 'empty query' do
        before do
          create(:query, provider: provider, field: :nickname, method: :contains, value: 'abc', query_set: query_set)
        end

        it 'returns nothing' do
          expect(service.scope.map(&:id)).to eq []
        end
      end

      context 'one query' do
        before do
          create(:query, provider: provider, field: :nickname, method: :contains, value: 'sean', query_set: query_set)
        end

        it 'returns filtered' do
          expect(service.scope.map(&:id)).to eq [bot_user_2].map(&:id)
        end
      end

      context 'many queries' do
        before do
          create(:query, provider: provider, field: :nickname, method: :contains, value: 'mike', query_set: query_set)
          create(:query, provider: provider, field: :email,    method: :contains, value: 'example', query_set: query_set)
        end

        it 'returns filtered' do
          expect(service.scope.map(&:id)).to eq [bot_user_3].map(&:id)
        end
      end

      context 'datetime queries' do
        context 'dashboard queries' do
          let!(:dashboard)      { create :dashboard, bot: bot, dashboard_type: 'custom', regex: 'abc' }
          let!(:included_user)  { create :bot_user, bot_instance: instance_1 }
          let!(:excluded_user)  { create :bot_user, bot_instance: instance_1 }
          let!(:event_1)        { create :event, created_at: 3.days.ago, user: included_user }
          let!(:event_2)        { create :event, created_at: 5.days.ago, user: excluded_user }
          let!(:de1)            { create :dashboard_event, dashboard: dashboard, event: event_1 }
          let!(:de2)            { create :dashboard_event, dashboard: dashboard, event: event_2 }

          before do
            create(:query,
              provider: provider, field: "dashboard:#{dashboard.uid}", method: :between,
              min_value: 4.days.ago, max_value: 2.days.ago,
              query_set: query_set
            )
          end

          it 'returns filtered' do
            expect(service.scope.map(&:id)).to match_array [included_user.id]
          end
        end

        context 'interacted_at' do
          before do
            create(:query,
              provider: provider, field: :interacted_at, method: :between,
              min_value: 4.days.ago, max_value: 2.days.ago,
              query_set: query_set
            )
          end

          it 'returns filtered' do
            expect(service.scope.map(&:id)).to match_array [user.id]
          end
        end

        context 'user_created_at' do
          before do
            create(:query,
              provider: provider, field: :user_created_at, method: :between,
              min_value: 8.days.ago, max_value: 6.days.ago,
              query_set: query_set
            )
          end

          it 'returns filtered' do
            one_week_user = create(:bot_user, created_at: 7.days.ago, bot_instance: instance_1)

            expect(service.scope.map(&:id)).to match_array [one_week_user.id]
          end
        end
      end
    end
  end
end
