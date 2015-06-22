# do not perform any physical downloads
require 'ruby_bittorrent'
BitTorrent.class_eval do
  def download!
    true
  end
end
