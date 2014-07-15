FactoryGirl.define do

  factory :video do
    from_file do
      begin
        FileUtils.mkdir_p(Rails.root.join('/tmp/test'))
      rescue # rubocop:disable HandleExceptions
      end
      FileUtils.cp(
        Rails.root.join('db/seeds/videos/example.m4v'),
        Rails.root.join('/tmp/test/example.m4v')
      )
      Rails.root.join('/tmp/test/example.m4v')
    end
  end

  factory :video_one_second, parent: :video do
    from_file do
      begin
        FileUtils.mkdir_p(Rails.root.join('/tmp/test'))
      rescue # rubocop:disable HandleExceptions
      end
      FileUtils.cp(
        Rails.root.join('db/seeds/videos/one_second.m4v'),
        Rails.root.join('/tmp/test/one_second.m4v')
      )
      Rails.root.join('/tmp/test/one_second.m4v')
    end
  end

  factory :video_one_second_2nd, parent: :video do
    from_file do
      begin
        FileUtils.mkdir_p(Rails.root.join('/tmp/test'))
      rescue # rubocop:disable HandleExceptions
      end
      FileUtils.cp(
        Rails.root.join('db/seeds/videos/one_second_2nd.mp4'),
        Rails.root.join('/tmp/test/one_second_2nd.mp4')
      )
      Rails.root.join('/tmp/test/one_second_2nd.mp4')
    end
  end

  factory :video_one_second_3rd, parent: :video do
    from_file do
      begin
        FileUtils.mkdir_p(Rails.root.join('/tmp/test'))
      rescue # rubocop:disable HandleExceptions
      end
      FileUtils.cp(
        Rails.root.join('db/seeds/videos/one_second_3rd.mp4'),
        Rails.root.join('/tmp/test/one_second_3rd.mp4')
      )
      Rails.root.join('/tmp/test/one_second_3rd.mp4')
    end
  end

  factory :video_one_second_4th, parent: :video do
    from_file do
      begin
        FileUtils.mkdir_p(Rails.root.join('/tmp/test'))
      rescue # rubocop:disable HandleExceptions
      end
      FileUtils.cp(
        Rails.root.join('db/seeds/videos/one_second_4th.mp4'),
        Rails.root.join('/tmp/test/one_second_4th.mp4')
      )
      Rails.root.join('/tmp/test/one_second_4th.mp4')
    end
  end

  factory :video_unseen, parent: :video_one_second do
    seen false
  end

  factory :video_liked, parent: :video_one_second_2nd do
    seen true
    like true
  end

  factory :video_not_liked, parent: :video_one_second_3rd do
    seen true
    like false
  end

  factory :video_not_liked_lately, parent: :video_one_second_4th do
    seen true
    like false
    created_at 2.hours.ago
    updated_at 2.hours.ago
  end

  factory :video_streamable, parent: :video do
    from_file do
      begin
        FileUtils.mkdir_p(Rails.root.join('/tmp/test'))
      rescue # rubocop:disable HandleExceptions
      end
      FileUtils.cp(
        Rails.root.join('db/seeds/videos/streamable.mp4'),
        Rails.root.join('/tmp/test/streamable.mp4')
      )
      Rails.root.join('/tmp/test/streamable.mp4')
    end
  end

end
