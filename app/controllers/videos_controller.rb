# operates on videos (unconditional)
class VideosController < ApplicationController
  def index
    @videos = Video.order('videos.created_at DESC').page(params[:page])
  end

  def show
    @video = Video.find(params[:id])
    @video.seen!
  end

  def update
    video = Video.find(params[:id])
    video.all_flags.each do |flag|
      video.send("#{flag}=", params[:video][flag])
    end
    video.save!
    render nothing: true
  end
end
