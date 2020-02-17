# frozen_string_literal: true

require 'uri'
require 'net/http'

require_relative 'network'

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
    include ::Lgtm::Network

    LGTM_URL = 'https://www.lgtm.app'.freeze

    RANDOM_POST_PATH = '/g'.freeze
    POST_CONTENT_PATH = '/p'.freeze

    # check_lgtm Comment LGTM markdown if report has no violations
    #
    # @param  [String] image_url LGTM image url
    # @param  [Boolean] https_image_only Use only secure url
    #
    # @return  [nil]
    #
    def check_lgtm(image_url: nil, https_image_only: false)
      return if status_report[:errors].any?
      return if status_report[:warnings].any?

      if image_url
        comment image_url
      else
        comment fetch_image_url(https_image_only)
      end
    end

    private

    # comment Place markdown comment
    #
    # @param  [Boolean] url LGTM image url
    #
    # @return  [nil]
    #
    def comment(url)
      if url.nil?
        markdown("<h1 align='center'>LGTM</h1>")
      else
        markdown("<p align='center'><img src='#{url}' alt='LGTM' /></p>")
      end
    end

    # fetch_image_url Fetch LGTM image url from https://www.lgtm.app
    #
    # @param  [Boolean] reject_insecure_url Eeturn only secure url
    #
    # @return  [String] LGTM image url
    #
    def fetch_image_url(reject_insecure_url = false)
      post_id = fetch_randon_post_id
      return if post_id.empty?

      post_content_url = fetch_post_content_url(post_id)
      return if post_content_url.empty?

      return fetch_image_url(reject_insecure_url) if retry?(reject_insecure_url,
                                                            post_content_url)

      post_content_url
    rescue ::Lgtm::Network::NetworkError => e
      $stdout.puts e.message
    end

    # fetch_randon_post_id Fetch renadon LGTM post url from https://www.lgtm.app
    #
    # @return  [String] LGTM post url
    #
    def fetch_randon_post_id
      uri = URI.join(LGTM_URL, RANDOM_POST_PATH)
      response = process_request(uri)
      location = parse_redirect_location(response)

      location.split('/').last
    end

    # fetch_post_content_url Fetch LGTM image url from https://www.lgtm.app
    #
    # @param  [String] post_id LGTM post identifier
    #
    # @return  [String] LGTM image url
    #
    def fetch_post_content_url(post_id)
      uri = URI.join(LGTM_URL, POST_CONTENT_PATH, post_id)
      response = process_request(uri)

      parse_redirect_location(response)
    end

    # retry? Check should be image url requested again
    #
    # @param  [Boolean] reject_insecure_url Return only secure url
    # @param  [String] url LGTM image url
    #
    # @return  [Boolean] should be image url requested again
    #
    def retry?(reject_insecure_url, url)
      reject_insecure_url && https?(URI.parse(url))
    end
  end
end
