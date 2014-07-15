FactoryGirl.define do

  factory :bad_word do
    sequence(:word) { |n| "Word#{n}" }
  end

end
