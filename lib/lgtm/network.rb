# frozen_string_literal: true

module Lgtm
  # Network is module of HTTP communication
  module Network
    class NetworkError < StandardError; end

    # process_request Send HTTP request
    #
    # @param  [URI] uri Request uri
    #
    # @return  [Net::HTTP] HTTP response
    #
    def process_request(uri)
      request = Net::HTTP::Get.new(uri)
      connection = Net::HTTP.start(uri.hostname, uri.port, use_ssl: https?(uri))

      connection
        .request(request)
        .tap(&method(:validate_response!))
    end

    # parse_redirect_location Parse redirect location from response
    #
    # @param [Net::HTTP] response HTTP response
    #
    # @return  [String] Redirect location
    #
    def parse_redirect_location(response)
      response['location']
    end

    private

    # validate_response! Validates HTTP response
    #
    # @param [Net::HTTP] response Net::HTTP response
    #
    # @raise NetworkError
    #
    # @return [nil]
    #
    def validate_response!(response)
      raise NetworkError, response.message if response.is_a?(Net::HTTPError)
    end

    # https? Check that uri use HTTPS scheme
    #
    # @param [URI] uri Test uri
    #
    # @return [Boolean] Result of check
    #
    def https?(uri)
      uri.instance_of?(URI::HTTPS)
    end
  end
end
