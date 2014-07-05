require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Rkanren
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end

  # Systemwide constants

  # Mapping between kind (id) and kind (string representation)
  # Access as Rkanren::NAME
  # Note: The numbering is NOT arbitrary. The application requests, that
  # the representation in the own language has code 0, and the optional
  # representations have the highest numbers. Since we have only three
  # representations, one of them being opitional, this leaves no other
  # possibility for numbering them.
  GAIGO=0
  KANA=1
  KANJI=2
  KINDS=[GAIGO,KANA,KANJI]
  NREPS=KINDS.size
  # How to present a kind to the user.
  # The application shall NOT assume, that KIND_PP[GAIGO] is the null string.
  # It *can* assume, that the other KIND_PP elements are NOT the null string.
  KIND_PP=['','カナ','漢字']
  # How to present a kind in the debug output.
  # It is guaranteed that all KIND_TXT elements have at least length 1
  KIND_TXT=['gaigo','kana','kanji']
  # Each representation can have a note attached.
  KIND_REP_NOTE=KIND_TXT.map { |s| s+'_notes' }

  # Sequences to be queried
  QUERYSEQ=
  {
    GAIGO => [KANA,KANJI],
    KANA  => [GAIGO,KANJI],
    KANJI => [KANA,GAIGO]
  }

  # Maximum allowed number of entries per dict
  MAX_CARDS_PER_DICT=250

end
