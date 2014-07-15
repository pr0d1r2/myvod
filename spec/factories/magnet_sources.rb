FactoryGirl.define do

  factory :magnet_source do
    sequence(:magnet_keyword) { |n| "example#{n}" }
    sort_by ThePirateBay::SortBy::Relevance
    category ThePirateBay::Category::Video
    number_of_pages 2

    after(:build) do |magnet_source|
      magnet_source.class.skip_callback(:create, :after, :import_async)
    end

    factory :magnet_source_with_import_async do
      after(:create) { |magnet_source| magnet_source.send(:import_async) }
    end
  end

end
