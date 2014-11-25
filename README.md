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
- All downloads via TOR

Performance
-----------
- Tested on dedicated server (8core i7 + 32GB RAM + 6TB HDD) for 6 months -> video throughput ~300 per day
- 10 parallel downloads
- 1 transcoding (using all processor cores with renice of 20 aka lowest prio possible)
- 2-5 clients watching videos without any problems (not tested more)
- 4-6 load on server all the time (caused mostly by transcoding)
- You can significantly increase performance for multiple users when using ZFS + lot of RAM for cache (or even adding L2ARC SSD[s] cache)

Requirements
------------

- Https configured www server (example configuration for nginx in config/nginx).
- Tor proxy on host machine.
- FFmpeg for video conversions and thumbnailing.
- qtfaststart for video operations
- Redis for sidekiq/sidetiq support
- PostgreSQL for database

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
k.categories [ 207 ] # HD Movies (https://thepiratebay.se/browse/207)
k.save!
DailyMagnetSourcesImportWorker.perform_async
```

Development
-----------
- fork it
- clone it
- rbenv install 2.0.0-p598
- brew install ffmpeg
- brew install qtfaststart
- gem install bundler
- bundle
- bundle exec rake db:create && rake db:migrate && rake db:test:clone
- bundle exec rspec
- bundle exec guard

Deployment
----------
- cp config/deploy.yml.sample config/deploy.yml
- configure config/deploy.yml
- cap deploy

Contrubution
------------

- Pull requests welcome
- Please send suggestions to pr0d1r2@gmail.com
