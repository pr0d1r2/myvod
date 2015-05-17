class TorrentDetails
  attr_reader :torrent_id

  def initialize(torrent_id)
    @torrent_id = torrent_id
  end

  def files
    response[:files].to_i
  end

  def size
    response[:size].split("(").last.to_i
  end

  def uploaded
    response[:uploaded].to_time
  end

  def description
    response[:description]
  end

  private

  def response
    @response ||= ThePirateBay::Torrent.find(torrent_id)
  end
end
