RSpec.describe Query do
  context 'constants' do
    context 'FIELDS' do
      it 'keys include' do
        expect(Queries::Slack::FIELDS.keys).to match_array %w(
          nickname email full_name interaction_count
          interacted_at user_created_at
        )
      end
    end
  end

  context 'associations' do
    it { is_expected.to belong_to :query_set }
  end

  context 'validations' do
    subject { create :query }

    it { is_expected.to validate_presence_of :provider }
    it { is_expected.to validate_inclusion_of(:provider).in_array(%w(slack kik facebook telegram)) }

    it { is_expected.to validate_presence_of :field }
    it { is_expected.to validate_presence_of :method }

    context 'provider is slack (default)' do
      subject { build :slack_query }

      it { is_expected.to validate_inclusion_of(:field).in_array(Queries::Slack::FIELDS.keys) }

      specify do
        is_expected.to validate_inclusion_of(:method).
          in_array(
            Queries::Slack::STRING_METHODS.keys |
              Queries::Slack::NUMBER_METHODS.keys |
              Queries::Slack::DATETIME_METHODS.keys
          )
      end
    end

    context 'value' do
      context 'method is not "between"' do
        subject { build(:slack_query, method: ['equals_to', 'contains'].sample) }
        it { is_expected.to validate_presence_of :value }
      end

      context 'method is "between"' do
        subject { build(:slack_query, method: 'between') }
        it { is_expected.to_not validate_presence_of :value }
      end
    end

    context 'min_value' do
      context 'method is not "between"' do
        subject { build(:slack_query, method: ['equals_to', 'contains'].sample) }
        it { is_expected.to_not validate_presence_of :min_value }
      end

      context 'method is "between"' do
        subject { build(:slack_query, method: 'between') }
        it { is_expected.to validate_presence_of :min_value }
      end
    end

    context 'max_value' do
      context 'method is not "between"' do
        subject { build(:slack_query, method: ['equals_to', 'contains'].sample) }
        it { is_expected.to_not validate_presence_of :max_value }
      end

      context 'method is "between"' do
        subject { build(:slack_query, method: 'between') }
        it { is_expected.to validate_presence_of :max_value }
      end
    end
  end

  describe '#query_source' do
    it 'find query source' do
      allow(Queries::Finder).to receive(:for_type)

      Query.new(provider: 'provider').query_source

      expect(Queries::Finder).to have_received(:for_type).with('provider')
    end
  end

  describe '#is_string_query' do
    let(:source) { double(:query_source).as_null_object }

    before { allow(Queries::Finder).to receive(:for_type) { source } }

    it 'works' do
      query = Query.new(provider: 'provider')
      query.is_string_query?

      expect(source).to have_received(:is_string_query?).with(query.field)
    end
  end

  describe '#is_number_query' do
    let(:source) { double(:query_source).as_null_object }

    before { allow(Queries::Finder).to receive(:for_type) { source } }

    it 'works' do
      query = Query.new(provider: 'provider')
      query.is_number_query?

      expect(source).to have_received(:is_number_query?).with(query.field)
    end
  end

  describe '#is_datetime_query' do
    let(:source) { double(:query_source).as_null_object }

    before { allow(Queries::Finder).to receive(:for_type) { source } }

    it 'works' do
      query = Query.new(provider: 'provider')
      query.is_datetime_query?

      expect(source).to have_received(:is_datetime_query?).with(query.field)
    end
  end

  describe '#to_form_params' do
    let!(:query) { create(:slack_query) }

    it 'returns a hash' do
      expect(query.to_form_params).to eq({ provider: query.provider, field: query.field, method: query.method, value: query.value })
    end
  end
end
