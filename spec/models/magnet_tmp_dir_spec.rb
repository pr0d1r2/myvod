require 'spec_helper'

describe MagnetTmpDir do
  describe '.have_disk_space?' do
    before do
      FreeDiskSpace.should_receive(:gigabytes).with(
        MagnetTmpDir::PATH
      ).and_return(tmp_free_space)
    end
    subject { described_class.have_disk_space? }

    context 'when less than minimum disk space free on download tmp dir' do
      let(:tmp_free_space) { MagnetTmpDir::MINIMUM_FREE_DISK_SPACE - 0.1 }

      it { should be_false }
    end

    context 'when more than minimum disk space free on download tmp dir' do
      let(:tmp_free_space) { MagnetTmpDir::MINIMUM_FREE_DISK_SPACE + 0.1 }

      it { should be_true }
    end
  end

  describe '.sub_dirs' do
    let(:sub_dirs) { double }
    let(:response) { described_class.sub_dirs }

    it do
      Dir.should_receive(:glob).with(
        "#{MagnetTmpDir::PATH}/**"
      ).and_return(sub_dirs)
      response.should == sub_dirs
    end
  end

  describe '.cleanup_sub_dirs' do
    let(:ctime_older) { (13.hours.to_i + 1.minute.to_i).seconds.ago }
    let(:ctime_newer) { (12.hours.to_i - 1.minute.to_i).seconds.ago }
    let(:subdir_older) { double(ctime: ctime_older) }
    let(:subdir_newer) { double(ctime: ctime_newer) }
    let(:sub_dirs) { [subdir_older] }
    before do
      File.stub(:stat)
      File.should_receive(:stat).with(subdir_older).and_return(subdir_older)
      described_class.should_receive(:sub_dirs).and_return(sub_dirs)
    end
    subject { described_class.cleanup_sub_dirs }

    it { should == [subdir_older] }

    context 'when sub_dirs contain dir newer than minimum existance time' do
      let(:sub_dirs) { [subdir_older, subdir_newer] }
      before do
        File.should_receive(:stat).with(subdir_newer).and_return(subdir_newer)
      end

      it { should == [subdir_older] }
    end
  end

  describe '.cleanup!' do
    let(:sub_dir) { double }
    before do
      FileUtils.stub(:rm_rf)
      described_class.should_receive(:cleanup_sub_dirs).and_return([sub_dir])
    end
    after { described_class.cleanup! }

    it { FileUtils.should_receive(:rm_rf).with(sub_dir) }
  end
end
