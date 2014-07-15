# displays unseen videos
class UnseensController < ApplicationController
  def index
    @videos = Video.unseen.page(params[:page])
    render 'videos/index'
  end

  def show
    @video = Video.unseen.first
    show_video
  end
end
