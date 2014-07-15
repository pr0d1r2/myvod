# show videos orginals (unconditional)
class OrginalsController < ApplicationController
  def show
    @video = Video.find(params[:id])
    @video.seen!
    @show_orginal = true
    render 'videos/show'
  end
end
