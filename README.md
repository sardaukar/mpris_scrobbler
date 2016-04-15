# MPRIS Scrobbler

I sometimes listen to music using Audacious (I'm a sucker for classic Winamp skins), and I've noticed the Last.fm plugin doesn't work for me on Fedora 23. But I also noticed that it supports [MPRIS], and I've always wanted to play with D-Bus.

So this project scrobbles your tracks to Last.fm as long as Audacious is running concurrently, and its `MPRIS 2 Server` plugin is enabled. It's a quick and dirty hack, but I might come back to it in the future.

[MPRIS]: https://specifications.freedesktop.org/mpris-spec/latest/

## Installation

```ruby
gem install mpris_scrobbler
```

## Usage

It's a long running binary - feel free to use whatever daemon wrapper for it.
The first time you run it, it creates a `config.yml` file in your home folder. In it, you have to fill in your Last.fm app API key and secret (create a new app [here], no need for a callback URL). You also need to fill in your Last.fm username, in order to fetch your last scrobbled track and determine if it needs updating. Do not fill in the `session_key` key.

After you fill in the API keys in the config file, you need to run the binary one more time to generate a session key. After this, subsequent runs have no output.

You can try to change the `player` key to support other MPRIS 2 compliant players, but I haven't tried this. Submit an issue, and I'll have a look if it doesn't work for your player - but it should, in theory!

[here]: http://www.last.fm/api/account/create

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sardaukar/mpris_scrobbler.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

