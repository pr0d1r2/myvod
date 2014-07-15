# operates on raw magnets, mostly not used as workers auto-fetch them
class MagnetsController < ApplicationController
  def index
    @magnets = Magnet.unseen.page(params[:page])
  end

  def show
    @magnet = Magnet.find(params[:id])
    @magnet.seen = true
    @magnet.save! if @magnet.seen_changed?
  end

  def update
    magnet = Magnet.find(params[:id])
    magnet.all_flags.each do |flag|
      magnet.send("#{flag}=", params[:magnet][flag])
    end
    magnet.save!
    render nothing: true
  end
end
