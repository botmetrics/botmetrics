RSpec.describe Queries::Kik do
  subject { Queries::Kik.new }

  describe '#is_string_query?' do
    it 'query is a string' do
      expect(subject.is_string_query?('first_name')).to be true
    end

    it 'query isn`t a string' do
      expect(subject.is_string_query?('interacted_at')).to be false
    end

    it 'query doesn`t exist' do
      expect(subject.is_string_query?('fake')).to be false
    end
  end

  describe '#fields' do
    let!(:bot) { create :bot }

    let(:values) { Hash[
                     'first_name', 'First Name',
                     'last_name', 'Last Name',
                     'interaction_count', 'Number of Interactions with Bot',
                     'interacted_at', 'Last Interacted With Bot',
                     'user_created_at', 'Signed Up'
                   ] }

    it 'should return proper values' do
      expect(subject.fields(bot)).to eql values
    end
  end
end
