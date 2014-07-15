FactoryGirl.define do

  factory :failed_video do
    md5 'a' * 32
  end

  trait :one_second do
    md5 Digest::MD5.hexdigest(
      File.read(Rails.root.join('db/seeds/videos/one_second.m4v'))
    )
  end

end
