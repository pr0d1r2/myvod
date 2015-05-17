FactoryGirl.define do

  factory :magnet do
    magnet_source { FactoryGirl.create(:magnet_source) }
    link 'magnet:?xt=urn:btih:factory'
    title 'factory magnet'
    seeders 50
    leechers 30
    category 'Video'
    sequence(:torrent_id) { |n| n }
    url '/torrent/2/factory'
    seen false
    like false

    trait :seen do
      seen true
    end

    trait :liked do
      like true
    end

    trait :downloaded do
      after(:create) do |magnet|
        magnet.downloaded!
      end
    end

    trait :download_timeouted do
      after(:create) do |magnet|
        magnet.download_timeout!
      end
    end

    trait :download_errored do
      after(:create) do |magnet|
        magnet.download_error!
      end
    end

    trait :no_seeders do
      seeders 0
    end

    trait :low_total_seeders do
      seeders 4
      leechers 5
    end

    trait :seeders_and_lower_leechers do
      seeders 40
      leechers 20
    end

    trait :seeders_and_higher_leechers do
      seeders 40
      leechers 120
    end

    trait :with_real_torrent_id do
      torrent_id 6_232_477
      files 3
      size 890_732_416
      uploaded Time.new(2011, 3, 10, 10, 44, 47)
      description 'desc'
    end

    factory :magnet_seen, traits: [:seen]

    factory :magnet_liked, traits: [:seen, :liked]

    factory :magnet_downloaded, traits: [:seen, :liked, :downloaded]

    factory :magnet_with_download_timeout, traits: [
      :seen, :liked, :download_timeouted
    ]

    factory :magnet_with_download_error, traits: [
      :seen, :liked, :download_errored
    ]

    factory :magnet_without_seeders, traits: [:no_seeders]

    factory :magnet_with_low_total_seeders, traits: [:low_total_seeders]

    factory :magnet_with_seeders_and_lower_leechers, traits: [
      :seeders_and_lower_leechers
    ]

    factory :magnet_with_seeders_and_higher_leechers, traits: [
      :seeders_and_higher_leechers
    ]

    factory :magnet_with_real_torrent_id, traits: [
      :with_real_torrent_id
    ]
  end

end
