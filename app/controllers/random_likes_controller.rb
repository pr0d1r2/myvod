# show random like video (best included)
class RandomLikesController < ApplicationController
  def show
    @video = Video.like_random
    show_video
  end
end
