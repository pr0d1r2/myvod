# display videos marked as 'best'
class BestsController < ApplicationController
  def index
    @videos = Video.best.recently_updated.page(params[:page])
    render 'videos/index'
  end
end
