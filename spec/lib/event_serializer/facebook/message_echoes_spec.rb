RSpec.describe EventSerializer::Facebook::MessageEchoes do
  TIMESTAMP ||= 1458692752478

  describe '.new' do
    context 'invalid params' do
      it { expect { EventSerializer::Facebook.new(nil) }.to raise_error('SuppliedOptionIsNil') }
    end
  end

  describe '#serialize' do
    subject { EventSerializer::Facebook::MessageEchoes.new(data).serialize }

    let(:data) {
      {
        "sender":{
          "id":"USER_ID"
        },
        "recipient":{
          "id":"PAGE_ID"
        },
        "timestamp":TIMESTAMP,
        "message":{
          "is_echo":true,
          "mid":"mid.1457764197618:41d102a3e1ae206a38",
          "seq":73,
          "text":"hello, world!"
        }
      }
    }
    let(:serialized) {
      {
        data:  {
          event_type: "message",
          is_for_bot: false,
          is_im: false,
          is_from_bot: true,
          text: "hello, world!",
          provider: "facebook",
          created_at: Time.at(TIMESTAMP.to_f / 1000),
          event_attributes: {
            delivered: false,
            read: false,
            mid: "mid.1457764197618:41d102a3e1ae206a38",
            seq: 73 }},
        recip_info: {
          sender_id: "USER_ID", recipient_id: "PAGE_ID"
        }
      }
    }

    it { expect(subject).to eql serialized }
  end
end
