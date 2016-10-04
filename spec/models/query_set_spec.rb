RSpec.describe QuerySet do
  context 'associations' do
    it { is_expected.to belong_to :bot }

    it { is_expected.to have_many :queries }
    it { is_expected.to accept_nested_attributes_for :queries }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :bot_id }
    it { is_expected.to validate_presence_of :instances_scope }
    it { is_expected.to validate_inclusion_of(:instances_scope).in_array(%w(legit enabled)) }
    it { is_expected.to validate_presence_of :time_zone }
  end

  describe '#initial_user_collection' do
    let!(:bot)        { create(:bot) }
    let!(:instance_1) { create(:bot_instance, :with_attributes, uid: '123', bot: bot, state: 'pending') }
    let!(:instance_2) { create(:bot_instance, :with_attributes, uid: '456', bot: bot, state: 'enabled') }
    let!(:instance_3) { create(:bot_instance, :with_attributes, uid: '789', bot: bot, state: 'disabled') }
    let!(:bot_user_1) { create(:bot_user, bot_instance: instance_1) }
    let!(:bot_user_2) { create(:bot_user, bot_instance: instance_2) }
    let!(:bot_user_3) { create(:bot_user, bot_instance: instance_3) }

    it { expect(QuerySet.new(bot: bot, instances_scope: 'legit').initial_user_collection).to eq [bot_user_2, bot_user_3] }
    it { expect(QuerySet.new(bot: bot, instances_scope: 'enabled').initial_user_collection).to eq [bot_user_2] }

    it 'raises error' do
      expect {
        QuerySet.new(bot: bot, instances_scope: 'xxxxx').initial_user_collection
      }.to raise_exception "Houston, we have a 'xxxxx' problem!"
    end
  end

  describe '#to_form_params' do
    let(:query_set) { create(:query_set, :with_slack_queries) }

    it 'works' do
      expect(query_set.to_form_params).
        to match({ query_set: hash_including(:bot_id, :instances_scope, :time_zone, :queries_attributes) })

      expect(query_set.to_form_params[:query_set][:queries_attributes].keys[0]).to be_kind_of String

      expect(query_set.to_form_params[:query_set][:queries_attributes].values[0]).
        to match(hash_including(:provider, :field, :method, :value))
    end
  end
end
