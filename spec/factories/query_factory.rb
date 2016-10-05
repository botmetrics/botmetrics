FactoryGirl.define do
  factory :query do
    association :query_set, factory: :query_set
    provider 'slack'
    add_attribute :field, 'interaction_count'
    add_attribute :method, 'equals_to'
    add_attribute :value, 0
  end

  factory :slack_query, class: Query do
    association :query_set, factory: :query_set
    provider 'slack'
    add_attribute :field, 'nickname'
    add_attribute :method, 'contains'
    add_attribute :value, 'win'
  end

  factory :facebook_query, class: Query do
    association :query_set, factory: :query_set
    provider 'facebook'
    add_attribute :field, 'first_name'
    add_attribute :method, 'contains'
    add_attribute :value, 'win'
  end
end
