# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Danger
  # Lgtm let danger say lgtm when there is no violations.
  # Default use random lgtm image from [lgtm.in](https://lgtm.in).
  #
  # @example Post lgtm with a specific image
  #
  #          lgtm.check_lgtm image_url: 'http://some.iamge'
  #
  # @see  leonhartX/danger-lgtm
  # @tags lgtm, github
  #
  class DangerLgtm < Plugin
    RANDOM_LGTM_POST_URL = 'https://lgtm.in/g'.freeze

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

      image_url ||= fetch_image_url

      markdown(
        markdown_template(image_url)
      )
    end

    private

    def fetch_image_url
      lgtm_post_url = process_request(RANDOM_LGTM_POST_URL)['location']

      lgtm_post_response = process_request(lgtm_post_url) do |req|
        req['Accept'] = 'application/json'
      end

      lgtm_post = JSON.parse(lgtm_post_response.body)

      lgtm_post['actualImageUrl']
    end

    def process_request(url)
      uri = URI(url)

      req = Net::HTTP::Get.new(uri)

      yield req if block_given?

      Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
        http.request(req)
      end 
    end

    def markdown_template(image_url)
      "<p align='center'><img src='#{image_url}' alt='LGTM' /></p>"
    end
  end
end
