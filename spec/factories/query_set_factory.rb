FactoryGirl.define do
  factory :query_set do
    instances_scope { [:legit, :enabled].sample }
    association :bot, factory: :bot
    time_zone 'Pacific/Asia'

    trait :with_slack_queries do
      after :create do |qs|
        create :slack_query, query_set: qs
      end
    end

    trait :with_facebook_queries do
      after :create do |qs|
        create :facebook_query, query_set: qs
      end
    end
  end
end
