require 'net/http'

module Danger
  # Lgtm let danger say lgtm when there is no violations.
  # Default use random lgtm image from [lgtm.in](https://lgtm.in).
  #
  # @example Post lgtm with a specific image
  #
  #          lgtm.check_lgtm image_url: 'http://some.iamge'
  #
  # @see  Ke Xu/danger-lgtm
  # @tags lgtm, github
  #
  class DangerLgtm < Plugin
    # Check status report, say lgtm if no violations
    # Generates a `markdown` of a lgtm iamge.
    #
    # @param   [image_url] lgtm image url
    #
    # @return  [void]
    #
    def check_lgtm(image_url: nil)
      return unless status_report[:errors].length.zero? &&
                    status_report[:warnings].length.zero?
      unless image_url
        id = Net::HTTP.get_response('lgtm.in', '/g')['location'].split('/').last
        image_url = "https://lgtm.in/p/#{id}"
      end
      markdown("![LGTM](#{image_url})")
    end
  end
end
