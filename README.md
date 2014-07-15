MyVOD
-----

Self hosted video on demand solution with keyword based torrent auto-download via PirateBay using TOR.

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
