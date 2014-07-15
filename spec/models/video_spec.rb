require 'spec_helper'

describe Video do

  before { Video.destroy_all }

  let(:the_object) { FactoryGirl.build(:video_one_second) }

  describe '#ss' do
    let(:the_object) { Video.new }
    before { the_object.stub(seconds: 85) }
    subject { the_object.ss(percentage) }

    context do
      let(:percentage) { 10 }

      it { should == '00:00:08' }
    end

    context do
      let(:percentage) { 20 }

      it { should == '00:00:17' }
    end

    context do
      let(:percentage) { 30 }

      it { should == '00:00:25' }
    end

    context do
      let(:percentage) { 40 }

      it { should == '00:00:34' }
    end

    context do
      let(:percentage) { 50 }

      it { should == '00:00:42' }
    end

    context do
      let(:percentage) { 60 }

      it { should == '00:00:51' }
    end

    context do
      let(:percentage) { 70 }

      it { should == '00:00:59' }
    end

    context do
      let(:percentage) { 80 }

      it { should == '00:01:08' }
    end

    context do
      let(:percentage) { 90 }

      it { should == '00:01:16' }
    end

    context 'when video longer than 1 hour' do
      before { the_object.stub(seconds: 4000) }
      let(:percentage) { 90 }

      it { should == '01:00:00' }
    end
  end

  describe 'unique videos only' do
    let!(:existing_video) { FactoryGirl.create(:video_one_second) }
    let(:new_video) { FactoryGirl.build(:video_one_second) }

    it 'should not allow to insert same file twice' do
      new_video.save.should be_false
    end
  end

  describe '.create_from_file' do
    context 'when given proper file' do
      it 'should create file and return true' do
        lambda do
          Video.create_from_file(
            Rails.root.join('db/seeds/videos/one_second.m4v')
          ).should be_a(Video)
        end.should change(Video, :count).by(1)
      end

      context 'when parent object given' do
        let(:magnet) { FactoryGirl.create(:magnet) }

        it 'should create file and return true with videoable' do
          lambda do
            Video.create_from_file(
              Rails.root.join('db/seeds/videos/one_second_3rd.mp4'), magnet
            ).should be_a(Video)
          end.should change(Video, :count).by(1)
          video = Video.last
          videoable = video.videoable
          videoable.should == magnet
        end
      end
    end

    context 'when given not_existing file' do
      it 'should create file and return true' do
        lambda do
          expect do
            Video.create_from_file(Rails.root.join('db/seeds/videos/bad.m4v'))
          end.to raise_error(Errno::ENOENT)
        end.should_not change(Video, :count)
      end
    end
  end

  describe '.create_from_file!' do
    context 'when given proper file' do
      it 'should create file and return true' do
        lambda do
          Video.create_from_file!(
            Rails.root.join('db/seeds/videos/one_second.m4v')
          ).should be_a(Video)
        end.should change(Video, :count).by(1)
      end

      context 'when parent object given' do
        let(:magnet) { FactoryGirl.create(:magnet) }

        it 'should create file and return true with videoable' do
          lambda do
            Video.create_from_file!(
              Rails.root.join('db/seeds/videos/one_second_2nd.mp4'), magnet
            ).should be_a(Video)
          end.should change(Video, :count).by(1)
          video = Video.last
          videoable = video.videoable
          videoable.should == magnet
        end
      end
    end

    context 'when given not existing file' do
      it 'should create file and return true' do
        lambda do
          expect do
            Video.create_from_file!(Rails.root.join('db/seeds/videos/bad.m4v'))
          end.to raise_error(Errno::ENOENT)
        end.should_not change(Video, :count)
      end
    end
  end

  context 'when specific video was deleted before' do
    let!(:the_object) { FactoryGirl.create(:video_one_second) }
    before { the_object.destroy }

    it 'should not allow to create it again' do
      expect do
        FactoryGirl.create(:video_one_second)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'setting video as best resulting in make it like too' do
    subject { FactoryGirl.create(:video_one_second) }
    before do
      subject.best = true
      subject.save!
    end

    its(:like) { should be_true }
  end

  describe 'not_liked scope' do
    let!(:video_liked) { FactoryGirl.create(:video_liked) }
    let!(:video_not_liked) { FactoryGirl.create(:video_not_liked) }
    let!(:video_unseen) { FactoryGirl.create(:video_unseen) }
    subject { described_class.not_liked }

    it { should == [video_not_liked] }
  end

  describe 'not_liked_lately scope' do
    let!(:video_liked) { FactoryGirl.create(:video_liked) }
    let!(:video_not_liked) { FactoryGirl.create(:video_not_liked) }
    let!(:video_not_liked_lately) do
      FactoryGirl.create(:video_not_liked_lately)
    end
    let!(:video_unseen) { FactoryGirl.create(:video_unseen) }
    subject { described_class.not_liked_lately }

    it { should == [video_not_liked_lately] }
  end

  describe 'recently_updated scope' do
    let!(:video_liked) { FactoryGirl.create(:video_liked) }
    let!(:video_not_liked) { FactoryGirl.create(:video_not_liked) }
    before do
      video_liked.update_attribute(:like, false)
    end
    subject { described_class.recently_updated }

    it { should == [video_liked, video_not_liked] }
  end

  describe '.flush_not_liked!' do
    let!(:video_liked) { FactoryGirl.create(:video_liked) }
    let!(:video_not_liked) { FactoryGirl.create(:video_not_liked) }
    let!(:video_not_liked_lately) do
      FactoryGirl.create(:video_not_liked_lately)
    end
    let!(:video_unseen) { FactoryGirl.create(:video_unseen) }
    before { described_class.flush_not_liked! }
    subject { described_class.all }

    it { should == [video_liked, video_not_liked, video_unseen] }
  end

  describe '#non_unique?' do
    let(:video) { FactoryGirl.build(:video_one_second) }
    subject { video.non_unique? }

    it { should be_false }

    context 'when video exist in database' do
      let!(:existing_video) { FactoryGirl.create(:video_one_second) }

      it { should be_true }

      context 'even when destroyed' do
        before { existing_video.destroy }

        it { should be_true }
      end
    end
  end

  describe '#sample?' do
    let(:name) { 'example.mp4' }
    let(:seconds) { 1000 }
    let(:video) { Video.new }
    before { video.stub(name: name, seconds: seconds) }
    subject { video.send(:sample?) }

    it { should be_false }

    context 'when "name" include "sample"' do
      let(:name) { 'this-is-sample.mp4' }

      context 'and duration <80s' do
        let(:seconds) { 79 }

        it { should be_true }
      end

      context 'and duration =80s' do
        let(:seconds) { 80 }

        it { should be_false }
      end
    end
  end

  context 'when video is a sample' do
    subject { Video.new }
    before do
      subject.stub(
        seconds: 79,
        name: 'video-sample.avi',
        file_for_write: Rails.root.join('db/seeds/videos/one_second.m4v')
      )
    end

    its(:valid?) { should be_false }

    its(:not_importable?) { should be_true }
  end

  describe '#ss_at_thumbnail_index' do
    let(:video) { Video.new }
    before { video.stub(seconds: seconds) }
    let(:seconds) { 240 }
    subject { video.ss_at_thumbnail_index(index) }

    %w(
      0:00 0:10 0:20 0:30 0:40 0:50 1:00 1:10
      1:20 1:30 1:40 1:50 2:00 2:10 2:20 2:30
      2:40 2:50 3:00 3:10 3:20 3:30 3:40 3:50
    ).each_with_index do |returns, index_value|
      context "when index is #{index_value}" do
        let(:index) { index_value }

        it { should == "00:0#{returns}" }
      end
    end
  end

  describe '#seconds_at_thumbnail_index' do
    let(:video) { Video.new }
    before { video.stub(seconds: seconds) }
    let(:seconds) { 240 }
    subject { video.seconds_at_thumbnail_index(index) }

    %w(
      0   10  20  30  40  50  60  70
      80  90  100 110 120 130 140 150
      160 170 180 190 200 210 220 230
    ).each_with_index do |returns, index_value|
      context "when index is #{index_value}" do
        let(:index) { index_value }

        it { should == returns.to_f }
      end
    end
  end

  describe 'detailed thumbs' do
    let(:subject) { Video.new }
    before { subject.stub(seconds: seconds) }

    context 'when seconds is 59' do
      let(:seconds) { 59 }

      its(:number_of_detailed_thumb_styles) { should == 1 }

      its(:detailed_thumb_styles) do
        should == {
          detailed_thumb1: {
            geometry: '320x240#', format: 'jpg', time: '00:00:00'
          }
        }
      end
    end

    context 'when seconds is 60' do
      let(:seconds) { 60 }

      its(:number_of_detailed_thumb_styles) { should == 1 }

      its(:detailed_thumb_styles) do
        should == {
          detailed_thumb1: {
            geometry: '320x240#', format: 'jpg', time: '00:00:00'
          }
        }
      end
    end

    context 'when seconds is 61' do
      let(:seconds) { 61 }

      its(:number_of_detailed_thumb_styles) { should == 2 }

      its(:detailed_thumb_styles) do
        should == {
          detailed_thumb1: {
            geometry: '320x240#', format: 'jpg', time: '00:00:00'
          },
          detailed_thumb2: {
            geometry: '320x240#', format: 'jpg', time: '00:01:00'
          }
        }
      end
    end

    context 'when seconds is 119' do
      let(:seconds) { 119 }

      its(:number_of_detailed_thumb_styles) { should == 2 }

      its(:detailed_thumb_styles) do
        should == {
          detailed_thumb1: {
            geometry: '320x240#', format: 'jpg', time: '00:00:00'
          },
          detailed_thumb2: {
            geometry: '320x240#', format: 'jpg', time: '00:01:00'
          }
        }
      end
    end

    context 'when seconds is 120' do
      let(:seconds) { 120 }

      its(:number_of_detailed_thumb_styles) { should == 2 }

      its(:detailed_thumb_styles) do
        should == {
          detailed_thumb1: {
            geometry: '320x240#', format: 'jpg', time: '00:00:00'
          },
          detailed_thumb2: {
            geometry: '320x240#', format: 'jpg', time: '00:01:00'
          }
        }
      end
    end

    context 'when seconds is 121' do
      let(:seconds) { 121 }

      its(:number_of_detailed_thumb_styles) { should == 3 }

      its(:detailed_thumb_styles) do
        should == {
          detailed_thumb1: {
            geometry: '320x240#', format: 'jpg', time: '00:00:00'
          },
          detailed_thumb2: {
            geometry: '320x240#', format: 'jpg', time: '00:01:00'
          },
          detailed_thumb3: {
            geometry: '320x240#', format: 'jpg', time: '00:02:00'
          }
        }
      end
    end
  end

  describe '#ss_at_detailed_thumb' do
    let(:video) { Video.new }
    subject { video.ss_at_detailed_thumb(position) }

    context 'when position 1' do
      let(:position) { 1 }

      it { should == '00:00:00' }
    end

    context 'when position 2' do
      let(:position) { 2 }

      it { should == '00:01:00' }
    end

    context 'when position 3' do
      let(:position) { 3 }

      it { should == '00:02:00' }
    end
  end

  describe '#seconds_at_detailed_thumb' do
    let(:video) { Video.new }
    subject { video.seconds_at_detailed_thumb(position) }

    context 'when position 1' do
      let(:position) { 1 }

      it { should == 0 }
    end

    context 'when position 2' do
      let(:position) { 2 }

      it { should == 60 }
    end

    context 'when position 3' do
      let(:position) { 3 }

      it { should == 120 }
    end
  end

  describe '#normal_thumb_styles' do
    let(:video) { Video.new }
    before { video.stub(seconds: 120) }
    subject { video.send(:normal_thumb_styles) }

    it do
      should == {
        thumb1: {
          geometry: '320x240#', format: 'jpg', time: '00:00:00'
        },
        thumb2: {
          geometry: '320x240#', format: 'jpg', time: '00:00:05'
        },
        thumb3: {
          geometry: '320x240#', format: 'jpg', time: '00:00:10'
        },
        thumb4: {
          geometry: '320x240#', format: 'jpg', time: '00:00:15'
        },
        thumb5: {
          geometry: '320x240#', format: 'jpg', time: '00:00:20'
        },
        thumb6: {
          geometry: '320x240#', format: 'jpg', time: '00:00:25'
        },
        thumb7: {
          geometry: '320x240#', format: 'jpg', time: '00:00:30'
        },
        thumb8: {
          geometry: '320x240#', format: 'jpg', time: '00:00:35'
        },
        thumb9: {
          geometry: '320x240#', format: 'jpg', time: '00:00:40'
        },
        thumb10: {
          geometry: '320x240#', format: 'jpg', time: '00:00:45'
        },
        thumb11: {
          geometry: '320x240#', format: 'jpg', time: '00:00:50'
        },
        thumb12: {
          geometry: '320x240#', format: 'jpg', time: '00:00:55'
        },
        thumb13: {
          geometry: '320x240#', format: 'jpg', time: '00:01:00'
        },
        thumb14: {
          geometry: '320x240#', format: 'jpg', time: '00:01:05'
        },
        thumb15: {
          geometry: '320x240#', format: 'jpg', time: '00:01:10'
        },
        thumb16: {
          geometry: '320x240#', format: 'jpg', time: '00:01:15'
        },
        thumb17: {
          geometry: '320x240#', format: 'jpg', time: '00:01:20'
        },
        thumb18: {
          geometry: '320x240#', format: 'jpg', time: '00:01:25'
        },
        thumb19: {
          geometry: '320x240#', format: 'jpg', time: '00:01:30'
        },
        thumb20: {
          geometry: '320x240#', format: 'jpg', time: '00:01:35'
        },
        thumb21: {
          geometry: '320x240#', format: 'jpg', time: '00:01:40'
        },
        thumb22: {
          geometry: '320x240#', format: 'jpg', time: '00:01:45'
        },
        thumb23: {
          geometry: '320x240#', format: 'jpg', time: '00:01:50'
        },
        thumb24: {
          geometry: '320x240#', format: 'jpg', time: '00:01:55'
        }
      }
    end
  end

  describe '#video_styles' do
    let(:video) { Video.new }
    subject { video.send(:video_styles) }

    it do
      should == {
        ipod: {
          format: 'mp4',
          streaming: true,
          whiny: true,
          convert_options: {
            output: {
              :acodec  =>  'aac',
              :ac  =>  2,
              :strict => 'experimental',
              :ab => '128k',
              :vcodec => 'libx264',
              :vprofile => 'baseline',
              :preset => 'ultrafast',
              :level => 13,
              :maxrate => 900_000,
              :bufsize => 3_000_000,
              :f => 'mp4',
              :b => '900k',
              :r => 29,
              :fflags => '+genpts',
              :threads => 0,
              'profile:v' => 'baseline'
            }
          },
          geometry: '480x320'
        }
      }
    end
  end

  describe '#paperclip_styles' do
    let(:video) { Video.new }
    before { video.stub(seconds: 120) }
    subject { video.send(:paperclip_styles) }

    it do
      should == {
        ipod: {
          format: 'mp4',
          streaming: true,
          whiny: true,
          convert_options: {
            output: {
              :acodec  =>  'aac',
              :ac  =>  2,
              :strict => 'experimental',
              :ab => '128k',
              :vcodec => 'libx264',
              :vprofile => 'baseline',
              :preset => 'ultrafast',
              :level => 13,
              :maxrate => 900_000,
              :bufsize => 3_000_000,
              :f => 'mp4',
              :b => '900k',
              :r => 29,
              :fflags => '+genpts',
              :threads => 0,
              'profile:v' => 'baseline'
            }
          },
          geometry: '480x320'
        },
        thumb1: {
          geometry: '320x240#', format: 'jpg', time: '00:00:00'
        },
        thumb2: {
          geometry: '320x240#', format: 'jpg', time: '00:00:05'
        },
        thumb3: {
          geometry: '320x240#', format: 'jpg', time: '00:00:10'
        },
        thumb4: {
          geometry: '320x240#', format: 'jpg', time: '00:00:15'
        },
        thumb5: {
          geometry: '320x240#', format: 'jpg', time: '00:00:20'
        },
        thumb6: {
          geometry: '320x240#', format: 'jpg', time: '00:00:25'
        },
        thumb7: {
          geometry: '320x240#', format: 'jpg', time: '00:00:30'
        },
        thumb8: {
          geometry: '320x240#', format: 'jpg', time: '00:00:35'
        },
        thumb9: {
          geometry: '320x240#', format: 'jpg', time: '00:00:40'
        },
        thumb10: {
          geometry: '320x240#', format: 'jpg', time: '00:00:45'
        },
        thumb11: {
          geometry: '320x240#', format: 'jpg', time: '00:00:50'
        },
        thumb12: {
          geometry: '320x240#', format: 'jpg', time: '00:00:55'
        },
        thumb13: {
          geometry: '320x240#', format: 'jpg', time: '00:01:00'
        },
        thumb14: {
          geometry: '320x240#', format: 'jpg', time: '00:01:05'
        },
        thumb15: {
          geometry: '320x240#', format: 'jpg', time: '00:01:10'
        },
        thumb16: {
          geometry: '320x240#', format: 'jpg', time: '00:01:15'
        },
        thumb17: {
          geometry: '320x240#', format: 'jpg', time: '00:01:20'
        },
        thumb18: {
          geometry: '320x240#', format: 'jpg', time: '00:01:25'
        },
        thumb19: {
          geometry: '320x240#', format: 'jpg', time: '00:01:30'
        },
        thumb20: {
          geometry: '320x240#', format: 'jpg', time: '00:01:35'
        },
        thumb21: {
          geometry: '320x240#', format: 'jpg', time: '00:01:40'
        },
        thumb22: {
          geometry: '320x240#', format: 'jpg', time: '00:01:45'
        },
        thumb23: {
          geometry: '320x240#', format: 'jpg', time: '00:01:50'
        },
        thumb24: {
          geometry: '320x240#', format: 'jpg', time: '00:01:55'
        },
        detailed_thumb1: {
          geometry: '320x240#', format: 'jpg', time: '00:00:00'
        },
        detailed_thumb2: {
          geometry: '320x240#', format: 'jpg', time: '00:01:00'
        }
      }
    end
  end

  describe '#detailed_url' do
    let(:video) { Video.new }
    let(:video_object) { double }
    before do
      video.stub(
        :orginal_streamable? => original_streamable,
        :video => video_object
      )
    end
    subject { video.detailed_url }

    context 'when original is streamable' do
      let(:original_streamable) { true }
      before do
        video_object.should_receive(:url).with(:original).and_return('x')
      end

      it { should == 'x' }
    end

    context 'when original is not streamable' do
      let(:original_streamable) { false }
      before do
        video_object.should_receive(:url).with(:ipod).and_return('y')
      end

      it { should == 'y' }
    end
  end

  context 'when failed video exist for given one' do
    let!(:failed_video) { FactoryGirl.create(:failed_video, :one_second) }
    subject { FactoryGirl.build(:video_one_second) }

    it { should_not be_valid }
  end

  context 'when video size greater than 2GB' do
    subject { FactoryGirl.create(:video_one_second) }
    before { subject.video_file_size = 2_190_363_873 }

    it { subject.save! }
  end

  describe '#detailed_thumbnails' do
    let(:video) { Video.new }
    before { video.stub(seconds: seconds) }
    subject { video.detailed_thumbnails }

    context 'when video has 10 minutes' do
      let(:seconds) { 10.minutes }

      it do
        should == {
          0    => :detailed_thumb1,
          60   => :detailed_thumb2,
          120  => :detailed_thumb3,
          180  => :detailed_thumb4,
          240  => :detailed_thumb5,
          300  => :detailed_thumb6,
          360  => :detailed_thumb7,
          420  => :detailed_thumb8,
          480  => :detailed_thumb9,
          540  => :detailed_thumb10,
        }
      end
    end

    context 'when video has 10 minutes 1 second' do
      let(:seconds) { 10.minutes + 1 }

      it do
        should == {
          0    => :detailed_thumb1,
          60   => :detailed_thumb2,
          120  => :detailed_thumb3,
          180  => :detailed_thumb4,
          240  => :detailed_thumb5,
          300  => :detailed_thumb6,
          360  => :detailed_thumb7,
          420  => :detailed_thumb8,
          480  => :detailed_thumb9,
          540  => :detailed_thumb10,
          600  => :detailed_thumb11,
        }
      end
    end
  end

  describe '#preview_thumbnails' do
    let(:video) { Video.new }
    before { video.stub(seconds: seconds) }
    subject { video.preview_thumbnails }

    context 'when video has 10 minutes' do
      let(:seconds) { 10.minutes }

      it do
        should == {
          0    => :thumb1,
          25   => :thumb2,
          50   => :thumb3,
          75   => :thumb4,
          100  => :thumb5,
          125  => :thumb6,
          150  => :thumb7,
          175  => :thumb8,
          200  => :thumb9,
          225  => :thumb10,
          250  => :thumb11,
          275  => :thumb12,
          300  => :thumb13,
          325  => :thumb14,
          350  => :thumb15,
          375  => :thumb16,
          400  => :thumb17,
          425  => :thumb18,
          450  => :thumb19,
          475  => :thumb20,
          500  => :thumb21,
          525  => :thumb22,
          550  => :thumb23,
          575  => :thumb24,
        }
      end
    end
  end

  describe '#all_thumbnails' do
    let(:video) { Video.new }
    before { video.stub(seconds: seconds) }
    subject { video.all_thumbnails }

    context 'when video has 10 minutes' do
      let(:seconds) { 10.minutes }

      it do
        should == {
          0    => :thumb1,
          25   => :thumb2,
          50   => :thumb3,
          60   => :detailed_thumb2,
          75   => :thumb4,
          100  => :thumb5,
          120  => :detailed_thumb3,
          125  => :thumb6,
          150  => :thumb7,
          175  => :thumb8,
          180  => :detailed_thumb4,
          200  => :thumb9,
          225  => :thumb10,
          240  => :detailed_thumb5,
          250  => :thumb11,
          275  => :thumb12,
          300  => :thumb13,
          325  => :thumb14,
          350  => :thumb15,
          360  => :detailed_thumb7,
          375  => :thumb16,
          400  => :thumb17,
          420  => :detailed_thumb8,
          425  => :thumb18,
          450  => :thumb19,
          475  => :thumb20,
          480  => :detailed_thumb9,
          500  => :thumb21,
          525  => :thumb22,
          540  => :detailed_thumb10,
          550  => :thumb23,
          575  => :thumb24,
        }
      end
    end
  end
end
