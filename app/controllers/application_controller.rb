# main application controller
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include UserAgentDetection

  protected

  def show_video
    if ios_device?
      show_ios
    else
      show_desktop
    end
  end

  def show_ios
    if @video
      @video.seen = true
      @video.save! if @video.seen_changed?
      render 'videos/show'
    else
      show_ios_videos_index
    end
  end

  def show_ios_videos_index
    if Video.like.count > 0
      @videos = Video.like.recently_updated.page(params[:page])
      render 'videos/index'
    else
      @videos = Video.recently_updated.page(params[:page])
      render 'videos/index'
    end
  end

  def show_desktop
    if @video
      redirect_to video_path(@video)
    else
      redirect_to_videos_index
    end
  end

  def redirect_to_videos_index
    if Video.like.count > 0
      redirect_to likes_path
    else
      redirect_to videos_path
    end
  end
end
