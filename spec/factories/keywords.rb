FactoryGirl.define do

  factory :keyword do
    sequence(:keyword) { |n| "keyword#{n}" }
    categories [100]
  end

end
