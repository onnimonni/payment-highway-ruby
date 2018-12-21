module PaymentHighway
  class BatchReport
    attr_reader :settlements, :result, :request_id, :response_id, :url
    def initialize(config:, date:)
      response, result = Api.new(config: config).get_batch(date: date)
      @settlements = result['settlements']
      @result = result['result']
      @url = response.env.url.to_s
      @request_id = response.env.response_headers['sph-request-id']
      @response_id = response.env.response_headers['sph-response-id']
    end
  end
end
