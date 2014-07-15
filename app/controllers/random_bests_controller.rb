# shows random best video
class RandomBestsController < ApplicationController
  def show
    @video = Video.best_random
    show_video
  end
end
