# videos related helpers
module VideosHelper
  def show_first_unseen_button(message = 'show first unseen')
    [
      '<span>',
      link_to(message, unseen_path(1), class: 'btn btn-primary'),
      unseens_to_see,
      '</span>'
    ].join(' ').html_safe
  end

  def unseens_to_see
    ['(', unseen_count, 'to see', ')'].join(' ')
  end

  def unseen_count
    @unseen_count ||= Video.unseen_count
  end

  def video_thumbnail_link(video, format, i)
    link_to(
      image_tag(video.video.url(format)),
      '#',
      onclick: video_thumbnail_onclick(video, i)
    )
  end

  def video_thumbnail_onclick(video, time)
    'jQuery("#video")["0"].currentTime = ' +
    time.to_s +
    ';' +
    '$("html, body").animate({' +
      'scrollTop: $("#video").offset().top' +
    '}, 200);' +
    'jQuery("#video")["0"].play();' +
    'return false;'
  end

  def video_backward_1min_button
    link_to(
      'backward_1min',
      '#',
      class: 'btn',
      onclick: video_backward_1min_onclick
    )
  end

  def video_backward_1min_onclick
    'video_time = jQuery("#video")["0"].currentTime;' +
    'video_time = video_time - 60;' +
    'jQuery("#video")["0"].currentTime = video_time;' +
    'return false;'
  end

  def video_forward_1min_button
    link_to(
      'forward_1min',
      '#',
      class: 'btn',
      onclick: video_forward_1min_onclick
    )
  end

  def video_forward_1min_onclick
    'video_time = jQuery("#video")["0"].currentTime;' +
    'video_time = video_time + 60;' +
    'jQuery("#video")["0"].currentTime = video_time;' +
    'return false;'
  end
end
