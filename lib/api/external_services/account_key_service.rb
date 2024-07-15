module Api
  module ExternalServices
    class AccountKeyService
      BASE_URL = 'https://w7nbdj3b3nsy3uycjqd7bmuplq0yejgw.lambda-url.us-east-2.on.aws'

      def self.gather_account_key(email: , key:)
        post_request(email, key)

        request_succeed? ? @request[:account_key] : @request
      end

      def self.request_succeed?
        @request.dig(:account_key).present?
      end

      private
        def self.post_request(email, key)
          @request = Request.post(
            "#{BASE_URL}/v1/account",
            payload(email, key),
            headers
          )  
        end

        def self.payload(email, key)
          { email: email, key: key }
        end

        def self.headers
          { content_type: 'application/json' }
        end
    end
  end
end