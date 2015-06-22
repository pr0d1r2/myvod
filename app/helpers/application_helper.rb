# whole app helpers
module ApplicationHelper
  def navigation_options # rubocop:disable MethodLength
    {
      'first unseen' => { short_name: 'n', path: unseen_path(1) },
      'unseens' => { short_name: 'u', path: unseens_path },
      'videos' => { short_name: 'v', path: videos_path },
      'likes' => { short_name: 'l', path: likes_path },
      'bests' => { short_name: 'b', path: bests_path },
      'magnets' => { short_name: 'm', path: magnets_path },
      'random(best)' => { short_name: 'rb', path: random_best_path(1) },
      'random(like)' => { short_name: 'rl', path: random_like_path(1) },
      'sidekiq' => { short_name: 's', path: '/sidekiq' }
    }
  end

  def short_navigation_options
    Hash[
      navigation_options.values.map do |option|
        [option[:short_name], option[:path]]
      end
    ]
  end

  def long_navigation_options
    Hash[navigation_options.map { |name, details| [name, details[:path]] }]
  end

  def menuitem(name, path)
    [
      menuitem_li(path),
      link_to(name, path),
      '</li>'
    ].join(' ').html_safe
  end

  def menuitem_li(path)
    if request.fullpath == path
      '<li class="active">'
    else
      '<li>'
    end
  end
end
