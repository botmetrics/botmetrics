RSpec.describe KikEventsService do
  let!(:admin_user)   { create :user }
  let!(:timestamp)    { Time.now.to_i * 1000 }
  let!(:bot)          { create :bot, provider: 'kik' }
  let!(:bc1)          { create :bot_collaborator, bot: bot, user: admin_user }
  let!(:bot_instance) { create :bot_instance, provider: 'kik', bot: bot }
  let!(:kik_client)   { double(Kik) }
  let!(:first_name)   { Faker::Name.first_name }
  let!(:last_name)   { Faker::Name.last_name }
  let!(:profile_pic_url)           { Faker::Internet.url }
  let!(:profile_pic_last_modified) { Faker::Date.between(2.days.ago, Date.today)  }

  def do_request
    KikEventsService.new(bot_id: bot.uid, events: events).create_events!
  end

  before do
    allow(Kik).to receive(:new).with(bot_instance.token, bot_instance.uid).and_return(kik_client)
    allow(kik_client).to receive(:call).
                     with("user/#{kik_user_id}", :get).
                     and_return(firstName: first_name,
                                lastName: last_name,
                                profilePicUrl: profile_pic_url,
                                profilePicLastModified: profile_pic_last_modified)
  end

  shared_examples "associates event with custom dashboard if custom dashboards exist" do
    let!(:dashboard1) { create :dashboard, bot: bot, regex: 'hello', dashboard_type: 'custom', provider: 'slack' }
    let!(:dashboard2) { create :dashboard, bot: bot, regex: 'eLLo', dashboard_type: 'custom', provider: 'slack' }
    let!(:dashboard3) { create :dashboard, bot: bot, regex: 'welcome', dashboard_type: 'custom', provider: 'slack' }

    it 'should associate events with dashboards that match the text' do
      do_request
      dashboard1.reload; dashboard2.reload; dashboard3.reload
      e = bot_instance.events.last

      expect(dashboard1.events.to_a).to eql [e]
      expect(dashboard2.events.to_a).to eql [e]
      expect(dashboard3.events.to_a).to be_empty
    end
  end

  shared_examples "should create an event as well as create the bot users" do
    it "should create an event" do
      expect {
        do_request
        bot_instance.reload
      }.to change(bot_instance.events, :count).by(1)

      event = bot_instance.events.last

      expect(event.event_type).to eql event_type
      expect(event.provider).to eql 'kik'
      expect(event.user).to eql BotUser.find_by(uid: kik_user_id)
      expect(event.event_attributes.slice(*required_event_attributes.keys)).to eql required_event_attributes
      expect(event.text).to eql text
      expect(event.created_at.to_i).to eql timestamp / 1000
      expect(event.is_from_bot).to be is_from_bot
      expect(event.is_im).to be is_im
      expect(event.is_for_bot).to be is_for_bot
    end

    it "should create a new BotUser" do
      expect {
        do_request
        bot_instance.reload
      }.to change(bot_instance.users, :count).by(1)

      user = bot_instance.users.last
      expect(user.user_attributes['first_name']).to eql first_name
      expect(user.user_attributes['last_name']).to eql last_name
      expect(user.user_attributes['profile_pic_url']).to eql profile_pic_url
      expect(user.user_attributes['profile_pic_last_modified']).to eql profile_pic_last_modified.to_s
      expect(user.uid).to eql kik_user_id
      expect(user.provider).to eql 'kik'
      expect(user.membership_type).to eql 'user'
    end

    it 'should increment bot_interaction_count if is_for_bot, otherwise do not increment' do
      do_request
      user = bot_instance.users.last

      if is_for_bot
        expect(user.bot_interaction_count).to eql 1
      else
        expect(user.bot_interaction_count).to eql 0
      end
    end

    it "should set last_interacted_with_bot_at to the event's created_at timestamp if is_for_bot, otherwise don't do anything" do
      do_request
      user = bot_instance.users.last
      event = bot_instance.events.last

      if is_for_bot
        expect(user.last_interacted_with_bot_at).to eql event.created_at
      else
        expect(user.last_interacted_with_bot_at).to be_nil
      end
    end
  end

  shared_examples "should create an event but not create any bot users" do
    let!(:user)        { create :bot_user, provider: 'kik', bot_instance: bot_instance, uid: kik_user_id }

    it "should create an event" do
      expect {
        do_request
        bot_instance.reload
      }.to change(bot_instance.events, :count).by(1)

      event = bot_instance.events.last

      expect(event.event_type).to eql event_type
      expect(event.provider).to eql 'kik'
      expect(event.user).to eql user
      expect(event.event_attributes.slice(*required_event_attributes.keys)).to eql required_event_attributes
      expect(event.text).to eql text
      expect(event.created_at.to_i).to eql timestamp / 1000
      expect(event.is_from_bot).to be is_from_bot
      expect(event.is_im).to be is_im
      expect(event.is_for_bot).to be is_for_bot
    end

    it "should NOT create new BotUsers" do
      expect {
        do_request
        bot_instance.reload
      }.to_not change(bot_instance.users, :count)
    end

    it 'should increment bot_interaction_count if is_for_bot, otherwise do not increment' do
      if is_for_bot
        expect {
          do_request
          user.reload
        }.to change(user, :bot_interaction_count).from(0).to(1)
      else
        expect {
          do_request
          user.reload
        }.to_not change(user, :bot_interaction_count)
      end
    end

    it "should set last_interacted_with_bot_at to the event's created_at timestamp if is_for_bot, otherwise don't do anything" do
      if is_for_bot
        expect {
          do_request
          user.reload
        }.to change(user, :last_interacted_with_bot_at)

        expect(user.last_interacted_with_bot_at).to eql bot_instance.events.last.created_at
      else
        expect {
          do_request
          user.reload
        }.to_not change(user, :last_interacted_with_bot_at)
      end
    end
  end

  describe 'event sub_types' do
    let(:kik_user_id)   { "kik-user-id"  }
    let(:bot_user_id)   { bot.uid        }
    let(:text)          { event_text     }
    let(:event_type)    { 'message'      }
    let(:is_from_bot)   { false }
    let(:is_for_bot)    { true  }
    let(:is_im)         { false  }
    let(:required_event_attributes) {
      Hash["id", "id-1", "chat_id", "chat_id-1"]
    }

    context 'text sub_type' do
      let(:event_text) { 'Hello' }
      let(:events) {
        [
          {
            "chatId": required_event_attributes['chat_id'],
            "type": "text",
            "from": kik_user_id,
            "participants": [kik_user_id],
            "id": required_event_attributes['id'],
            "timestamp": timestamp,
            "body": text,
            "mention": nil
          }
        ]
      }
      let(:event_type) { 'message' }

      context "bot user exists" do
        it_behaves_like "should create an event as well as create the bot users"
        it_behaves_like "associates event with custom dashboard if custom dashboards exist"
      end

      context "bot user does not exist" do
        it_behaves_like "should create an event but not create any bot users"
        it_behaves_like "associates event with custom dashboard if custom dashboards exist"
      end
    end

    context 'link sub_type' do
      let(:event_text) { nil }
      let(:events) {
        [
          {
            "chatId": required_event_attributes['chat_id'],
            "type": "link",
            "from": kik_user_id,
            "participants": [kik_user_id],
            "id": required_event_attributes['id'],
            "timestamp": timestamp,
            "url": Faker::Internet.url,
            "attribution": {
                "name": "name",
                "iconUrl": Faker::Avatar.image("my-own-slug")
            },
            "noForward": true,
            "readReceiptRequested": true,
            "mention": nil
          }
        ]
      }
      let(:event_type) { 'message:link-uploaded' }

      context "bot user exists" do
        it_behaves_like "should create an event as well as create the bot users"
      end

      context "bot user does not exist" do
        it_behaves_like "should create an event but not create any bot users"
      end
    end

    context 'picture sub_type' do
      let(:event_text) { nil }
      let(:events) {
        [
          {
            "chatId": required_event_attributes['chat_id'],
            "type": "picture",
            "from": kik_user_id,
            "participants": [kik_user_id],
            "id": required_event_attributes['id'],
            "picUrl": "http://example.kik.com/apicture.jpg",
            "timestamp": timestamp,
            "readReceiptRequested": true,
            "attribution": {
                "name": "A Title",
                "iconUrl": "http://example.kik.com/anicon.png"
            },
            "mention": nil
          }
        ]
      }

      let(:event_type) { 'message:image-uploaded' }

      context "bot user exists" do
        it_behaves_like "should create an event as well as create the bot users"
      end

      context "bot user does not exist" do
        it_behaves_like "should create an event but not create any bot users"
      end
    end

    context 'video sub_type' do
      let(:event_text) { nil }
      let(:events) {
        [
          {
            "chatId": required_event_attributes['chat_id'],
            "type": "video",
            "from": kik_user_id,
            "participants": [kik_user_id],
            "id": required_event_attributes['id'],
            "timestamp": timestamp,
            "readReceiptRequested": true,
            "videoUrl": "http://example.kik.com/video.mp4",
            "attribution": {
                "name": "A Title",
                "iconUrl": "http://example.kik.com/anicon.png"
            },
            "mention": nil
          }
        ]
      }
      let(:event_type) { 'message:video-uploaded' }

      context "bot user exists" do
        it_behaves_like "should create an event as well as create the bot users"
      end

      context "bot user does not exist" do
        it_behaves_like "should create an event but not create any bot users"
      end
    end

    context 'start-chatting sub_type' do
      let(:event_text) { nil }
      let(:events) {
        [
          {
            "chatId": required_event_attributes['chat_id'],
            "type": "start-chatting",
            "from": kik_user_id,
            "participants": [kik_user_id],
            "id": required_event_attributes['id'],
            "timestamp": timestamp,
            "readReceiptRequested": false,
            "mention": nil
          }
        ]
      }

      let(:event_type) { 'message:start-chatting' }

      context "bot user exists" do
        it_behaves_like "should create an event as well as create the bot users"
      end

      context "bot user does not exist" do
        it_behaves_like "should create an event but not create any bot users"
      end
    end

    context 'scan-data sub_type' do
      let(:event_text) { nil }
      let(:events) {
        [
          {
            "chatId": required_event_attributes['chat_id'],
            "type": "scan-data",
            "from": kik_user_id,
            "participants": [kik_user_id],
            "id": required_event_attributes['id'],
            "timestamp": timestamp,
            "data": "{\"store_id\": \"2538\"}",
            "mention": nil
          }
        ]
      }
      let(:event_type) { 'message:scanned-data' }

      context "bot user exists" do
        it_behaves_like "should create an event as well as create the bot users"
      end

      context "bot user does not exist" do
        it_behaves_like "should create an event but not create any bot users"
      end
    end

    context 'sticker sub_type' do
      let(:event_text) { nil }
      let(:events) {
        [
          {
            "chatId": required_event_attributes['chat_id'],
            "type": "sticker",
            "id": required_event_attributes['id'],
            "timestamp": timestamp,
            "from": kik_user_id,
            "participants": [kik_user_id],
            "stickerPackId": "memes",
            "stickerUrl": "http://cards-sticker-dev.herokuapp.com/stickers/memes/okay.png",
            "readReceiptRequested": true,
            "mention": nil
          }
        ]
      }
      let(:event_type) { 'message:sticker-uploaded' }

      context "bot user exists" do
        it_behaves_like "should create an event as well as create the bot users"
      end

      context "bot user does not exist" do
        it_behaves_like "should create an event but not create any bot users"
      end
    end

    context 'is-typing sub_type' do
      let(:event_text) { nil }
      let(:events) {
        [
          {
            "chatId": required_event_attributes['chat_id'],
            "id": required_event_attributes['id'],
            "type": "is-typing",
            "from": kik_user_id,
            "participants": [kik_user_id],
            "timestamp": timestamp,
            "isTyping": false,
            "readReceiptRequested": false,
            "mention": nil
          }
        ]
      }
      let(:event_type) { 'message:is-typing' }

      context "bot user exists" do
        it_behaves_like "should create an event as well as create the bot users"
      end

      context "bot user does not exist" do
        it_behaves_like "should create an event but not create any bot users"
      end
    end

    context 'friend-picker sub_type' do
      let(:event_text) { nil }
      let(:events) {
        [
          {
            "chatId": required_event_attributes['chat_id'],
            "type": "friend-picker",
            "from": kik_user_id,
            "participants": [kik_user_id],
            "id": required_event_attributes['id'],
            "picked": ["aleem"],
            "timestamp": timestamp,
            "readReceiptRequested": true,
            "mention": nil
          }
        ]
      }
      let(:event_type) { 'message:friend-picker-chosen' }

      context "bot user exists" do
        it_behaves_like "should create an event as well as create the bot users"
      end

      context "bot user does not exist" do
        it_behaves_like "should create an event but not create any bot users"
      end
    end
  end

  describe '"delivery-receipt" event' do
    let(:kik_user_id)   { "kik-user-id"  }
    let(:bot_user_id)   { bot.uid        }
    let!(:user)         { create :bot_user, bot_instance: bot_instance, provider: 'kik' }
    let!(:first_name)   { Faker::Name.first_name }
    let!(:last_name)   { Faker::Name.last_name }
    let!(:profile_pic_url)           { Faker::Internet.url }
    let!(:profile_pic_last_modified) { Faker::Date.between(2.days.ago, Date.today)  }
    let!(:e1)    do
      create :event, user: user, bot_instance: bot_instance, event_type: 'message', provider: 'kik',
                     event_attributes: { id: "id-1", chat_id: "chat_id-1", sub_type: 'text' }
    end
    let!(:e2)    do
      create :event, user: user, bot_instance: bot_instance, event_type: 'message', provider: 'kik',
                     event_attributes: { id: "id-2", chat_id: "chat_id-1", sub_type: 'text' }
    end
    let!(:e3)    do
      create :event, user: user, bot_instance: bot_instance, event_type: 'message', provider: 'kik',
                     event_attributes: { id: "id-3", chat_id: "chat_id-1", sub_type: 'text' }
    end

    let(:events) {
      [
        {
          chatId: "chat_id",
          type: "delivery-receipt",
          from: kik_user_id,
          participants: [kik_user_id],
          id: "id",
          messageIds: ["id-1", "id-2"],
          timestamp: 1399303478832,
          readReceiptRequested: false,
          mention: nil
        }
      ]
    }

    it "should update the 'has_been_delivered' value for all of the events that belong to the bot_instance to 'true'" do
      skip "disabled until faster method to update events is found"

      do_request
      expect(e1.reload.has_been_delivered).to be true
      expect(e2.reload.has_been_delivered).to be true
      expect(e3.reload.has_been_delivered).to be false
    end
  end

  describe '"read-receipt" event' do
    let(:kik_user_id)   { "kik-user-id"  }
    let(:bot_user_id)   { bot.uid        }
    let!(:user)         { create :bot_user, bot_instance: bot_instance, provider: 'kik' }
    let!(:first_name)   { Faker::Name.first_name }
    let!(:last_name)   { Faker::Name.last_name }
    let!(:profile_pic_url)           { Faker::Internet.url }
    let!(:profile_pic_last_modified) { Faker::Date.between(2.days.ago, Date.today)  }
    let!(:e1)    do
      create :event, user: user, bot_instance: bot_instance, event_type: 'message', provider: 'kik',
                     event_attributes: { id: "id-1", chat_id: "chat_id-1", sub_type: 'text' }
    end
    let!(:e2)    do
      create :event, user: user, bot_instance: bot_instance, event_type: 'message', provider: 'kik',
                     event_attributes: { id: "id-2", chat_id: "chat_id-1", sub_type: 'text' }
    end
    let!(:e3)    do
      create :event, user: user, bot_instance: bot_instance, event_type: 'message', provider: 'kik',
                     event_attributes: { id: "id-3", chat_id: "chat_id-1", sub_type: 'text' }
    end

    let(:events) {
      [
        {
          chatId: "chat_id",
          type: "read-receipt",
          from: kik_user_id,
          participants: [kik_user_id],
          id: "id",
          messageIds: ["id-1", "id-2"],
          timestamp: 1399303478832,
          readReceiptRequested: false,
          mention: nil
        }
      ]
    }

    it "should update the 'has_been_read' value for all of the events that belong to the bot_instance to 'true'" do
      skip "disabled until faster method to update events is found"

      do_request
      expect(e1.reload.has_been_read).to be true
      expect(e2.reload.has_been_read).to be true
      expect(e3.reload.has_been_read).to be false
    end
  end
end
