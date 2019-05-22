# frozen_string_literal: true

module MyApiClient
  module Request
    include MyApiClient::Exceptions

    def request(method, url, headers, query, body)
      agent = Sawyer::Agent.new(endpoint)
      agent.call(method, url, body, headers: headers, query: query).data
    end

    %i[get post patch delete].each do |http_method|
      class_eval <<~METHOD, __FILE__, __LINE__ + 1
        def #{http_method}(url, headers: nil, query: nil, body: nil)
          request :#{http_method}, url, headers, query, body
        end
      METHOD
    end
    alias put patch
  end
end
