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
    # Generates a `markdown` of a lgtm image.
    #
    # @param   [image_url] lgtm image url
    # @param   [https_image_only] fetching https image only if true
    #
    # @return  [void]
    #
    def check_lgtm(image_url: nil, https_image_only: false)
      return unless status_report[:errors].length.zero? &&
                    status_report[:warnings].length.zero?

      image_url ||= fetch_image_url(https_image_only: https_image_only)

      markdown(
        markdown_template(image_url)
      )
    end

    private

    # returns "<h1 align="center">LGTM</h1>" when ServiceTemporarilyUnavailable.
    def fetch_image_url(https_image_only: false)
      return unless lgtm_post_url
      lgtm_post_response = process_request(lgtm_post_url) do |req|
        req['Accept'] = 'application/json'
      end

      lgtm_post = JSON.parse(lgtm_post_response.body)

      url = lgtm_post['actualImageUrl']
      if https_image_only && URI.parse(url).scheme != 'https'
        return fetch_image_url(https_image_only: true)
      end
      url
    end

    def process_request(url)
      uri = URI(url)

      req = Net::HTTP::Get.new(uri)

      yield req if block_given?

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
    end

    def lgtm_post_url
      lgtm_post_req = process_request(RANDOM_LGTM_POST_URL)
      return if lgtm_post_req.code == '503'
      lgtm_post_req['location']
    end

    def markdown_template(image_url)
      if image_url.nil?
        "<h1 align='center'>LGTM</h1>"
      else
        "<p align='center'><img src='#{image_url}' alt='LGTM' /></p>"
      end
    end
  end
end
