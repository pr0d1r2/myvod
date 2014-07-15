MyVOD
-----

Self hosted video on demand solution with keyword based torrent auto-download via PirateBay using TOR.

Features
--------

- Automatically download and transcode videos to quick preview format
- You can like video or make it best (separate views to navigate with huge amount of videos)
- Automatically remove seen but not liked videos
- Browse torrents (and possibility to make request of download by like it)
- Prevent filling up disk (by default downloads stops when 500GB free space)
- Tested on dedicated server (8core i7 + 32GB RAM + 6TB HDD) for 6 months -> video throughput ~300 per day
- All downloads via TOR

Requirements
------------

- Https configured www server (example configuration for nginx in config/nginx).
- Tor proxy on host machine.
- FFmpeg for video conversions and thumbnailing.
- Redis for sidekiq/sidetiq support

Setup
-----

- Use example configuration in config/nginx and replace MY_IP with your server ip address.
- Make user account with RVM installed.
- Use capistrano for deployments.
- Configure your http authentication in app/models/asset_host.rb

Usage
-----

- Deploy.
- Ensure that sidekiq works.
- Go to production console and create new keyword, for example:

```ruby
k = Keyword.new
k.keyword = "YIFY 1080p"
k.categories [ 207 ] # HD Movies
k.save!
DailyMagnetSourcesImportWorker.perform_async
```

Contrubution
------------

- Pull requests welcome
- Please send suggestions to pr0d1r2@gmail.com
