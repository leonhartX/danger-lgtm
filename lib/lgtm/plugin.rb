require 'net/http'

module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  Ke Xu/danger-lgtm
  # @tags monday, weekends, time, rattata
  #
  class DangerLgtm < Plugin
    def check_lgtm(image_url: nil)
      if status_report[:errors].length == 0 && status_report[:warnings].length == 0
        if !image_url
          id = Net::HTTP.get_response('lgtm.in', '/g')['location'].split('/').last
          image_url = "https://lgtm.in/p/#{id}"
        end
        markdown("![LGTM](#{image_url})")
      end
    end
  end
end