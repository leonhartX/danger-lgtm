module Lgtm
  # ErrorHandleable of module of error handling
  module ErrorHandleable
    # 4xx http status.
    CLIENT_ERRORS = [
      Net::HTTPBadRequest,
      Net::HTTPForbidden,
      Net::HTTPNotFound
    ].freeze
    # 5xx http status.
    SERVER_ERRORS = [
      Net::HTTPInternalServerError,
      Net::HTTPBadGateway,
      Net::HTTPServiceUnavailable,
      Net::HTTPGatewayTimeOut
    ].freeze

    def validate_response(response)
      case response
      when *SERVER_ERRORS
        raise ::Lgtm::Errors::UnexpectedError
      when *CLIENT_ERRORS
        raise ::Lgtm::Errors::UnexpectedError
      end
    end
  end
end
