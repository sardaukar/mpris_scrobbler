module MprisScrobbler
  require 'dbus'
  require 'rockstar'
  require 'yaml'
  class Spy

    CONFIG_DIR = "~/.config/mpris_scrobbler"
    CONFIG_FILE = "config.yml"

    def initialize
      @config =
        if File.exists?(config_file_path)
          load_config
        else
          gen_config
          puts "Config example saved to #{File.join(CONFIG_DIR, CONFIG_FILE)}"
          puts "Refer to the README file for next steps."
          exit(0)
        end

      init_rockstar
      ask_auth unless session_key

      @interface = get_dbus_interface
      @queue = []
    end

    def run
      user = Rockstar::User.new(lastfm_config["username"])
      last_track = user.recent_tracks.first.name rescue nil

      loop do
        current_track, artist, album, length = get_dbus_metadata

        if current_track != last_track
          @queue << {
            track: current_track,
            artist: artist.first,
            album: album,
            length: length,
            scrobbled: false
          }

          if queue.size == 1
            update_now_playing
          else
            scrobble_previous_track
            update_now_playing
          end

          last_track = current_track
        end

        trim_queue if queue.size > 5

        sleep sleep_period
      end
    end

    private
    attr_reader :interface, :config, :queue

    def trim_queue
      @queue = @queue[-3..-1]
    end

    def scrobble_previous_track
      track_info = queue[-2]
      return if track_info[:scrobbled]

      Rockstar::Track.scrobble(
        session_key: session_key,
        track: track_info[:track],
        artist: track_info[:artist],
        album: track_info[:album],
        time: Time.now - (track_info[:length] / 1_000_000),
        length: track_info[:length]
      )

      @queue[-2][:scrobbled] = true
    end

    def update_now_playing
      track_info = queue.last

      Rockstar::Track.updateNowPlaying(
        session_key: session_key,
        track: track_info[:track],
        artist: track_info[:artist],
        album: track_info[:album],
        time: Time.now,
        length: track_info[:length]
      )
    end

    def get_dbus_metadata
      interface["Metadata"].values_at(
        "xesam:title",
        "xesam:artist",
        "xesam:album",
        "mpris:length"
      )
    end

    def config_file_path
      File.expand_path(File.join(CONFIG_DIR, CONFIG_FILE))
    end

    def ask_auth
      auth = Rockstar::Auth.new
      token = auth.token

      puts
      puts "Please open http://www.last.fm/api/auth/?api_key=#{Rockstar.lastfm_api_key}&token=#{token}"
      puts
      puts "Press enter when done."

      gets

      session = auth.session(token)

      save_session(session)
    end

    def save_session(session)
      @config["lastfm"]["session_key"] = session.key

      File.open(config_file_path,"w") { |f| f.write @config.to_yaml }
    end

    def session_key
      lastfm_config["session_key"]
    end

    def sleep_period
      mpris_config["poll_every_seconds"]
    end

    def lastfm_config
      config["lastfm"]
    end

    def mpris_config
      config["mpris"]
    end

    def init_rockstar
      Rockstar.lastfm = {
        api_key: lastfm_config["api_key"],
        api_secret: lastfm_config["api_secret"]
      }
    end

    def gen_config
      require 'fileutils'
      FileUtils.mkdir_p File.expand_path(CONFIG_DIR)

      template = {
        lastfm: {
          username: "XXX",
          api_key: "XXX",
          api_secret: "XXX",
          session_key: nil
        },
        mpris: {
          player: "audacious",
          poll_every_seconds: 10
        }
      }

      File.open(config_file_path,"w") { |f| f.write template.to_yaml }
    end

    def load_config
      YAML.load_file(config_file_path)
    end

    def get_dbus_interface
      bus = DBus::SessionBus.instance
      service = bus.service("org.mpris.MediaPlayer2.#{mpris_config["player"]}")
      player = service.object("/org/mpris/MediaPlayer2")

      player.introspect
      player["org.mpris.MediaPlayer2.Player"]
    end
  end
end
