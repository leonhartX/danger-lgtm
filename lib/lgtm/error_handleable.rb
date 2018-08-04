module Lgtm
  module ErrorHandleable
    # 2xx http success status.
    SUCCESS_STATUSES = [Net::HTTPSuccess, Net::HTTPFound]
    # 4xx http status.
    CLIENT_ERRORS = [Net::HTTPBadRequest, Net::HTTPForbidden, Net::HTTPNotFound]
    # 5xx http status.
    SERVER_ERRORS = [
      Net::HTTPInternalServerError,
      Net::HTTPBadGateway,
      Net::HTTPServiceUnavailable,
      Net::HTTPGatewayTimeOut,
    ]

    def validate_response(response)
      case response
      when *SUCCESS_STATUSES
        # Nothing to do.
      when *SERVER_ERRORS
        raise ::Lgtm::Errors::UnexpectedError
      when *CLIENT_ERRORS
        raise ::Lgtm::Errors::UnexpectedError
      end
    end
  end
end
