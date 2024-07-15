module Api
  class Request
    def self.post(url, payload, headers)
      response = RestClient::Request.execute(
        method: :post,
        url: url,
        payload: payload.to_json,
        headers: headers
      )
        
      JSON.parse(response.body).with_indifferent_access
    rescue RestClient::SSLCertificateNotVerified => e
      Rails.logger.error '!!! It seems like the given URL is not correct'

      { 'message' => e.message, 'error' => e.http_code }.with_indifferent_access
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error '!!! Something went wrong with the POST request'
      Rails.logger.error "!!! It fails with error: #{e.http_code}"
      Rails.logger.error "!!! And with message: #{e.message}"
  
      { 'message' => e.message, 'error' => e.http_code }.with_indifferent_access
    end
  end
end