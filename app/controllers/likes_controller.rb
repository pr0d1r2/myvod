# display videos marked as 'liked'
class LikesController < ApplicationController
  def index
    @videos = Video.like.recently_updated.page(params[:page])
    render 'videos/index'
  end
end
