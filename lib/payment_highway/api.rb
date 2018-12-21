module PaymentHighway
  class Api
    def initialize(config:)
      @config = config
    end

    def get_batch(date:)
      get "/report/batch/#{date.strftime('%Y%m%d')}"
    end

    private

    def get(resource)
      response = Faraday.new(url: @config.service).get do |req|

        req.headers['Content-Type'] = 'application/json'

        # Add Payment Highway specific headers
        signed_headers(
          method: 'GET',
          uri: resource,
          config: @config,
          values: [],
        ).each do |header, value|
          req.headers[header] = value
        end

        req.url resource
      end

      validate(response)

      [response, JSON.parse(response.body)]
    end

    def signed_headers(method:, uri:, config:, values:, body: "", timestamp: Time.now.utc.strftime('%FT%TZ'), request_id: SecureRandom.uuid)
      headers = {
        'sph-account': config.account,
        'sph-merchant': config.merchant,
        'sph-timestamp': timestamp,
        'sph-request-id': request_id,
        'sph-api-version': config.version,
      }.compact # Removes optional nil parameters
      headers.merge({ signature: Signer.signature(config: config, method: method, uri: uri, headers: headers, body: body) })
    end

    def validate(response)
      # If server did not respond with 200 output the error message from the body
      unless response.status == 200
        raise Error, response.body
      end

      missing_mandatory_headers = [
        'sph-timestamp',
        'sph-request-id',
        'sph-response-id',
        'signature'
      ] - response.env[:response_headers].keys
      unless missing_mandatory_headers.empty?
        raise Error, "Mandatory headers #{missing_mandatory_headers} are missing from response"
      end
      # SPEC: the timestamp must be checked and it must not differ more than five (5) minutes from the correct global UTC time
      if (Time.now - Time.parse(response.env[:response_headers]['sph-timestamp'])) > 5 * 60
        raise Error, "Latency between server and client was over 5 minutes. Results should not be trusted!"
      end
      # SPEC: Check that request and response headers were the same
      if response.env[:response_headers]['sph-request-id'] != response.env[:request_headers]['sph-request-id']
        raise Error, "sph-request-id mismatch! request: (#{response.env[:request_headers]['sph-request-id']}) was not response: (#{response.env[:response_headers]['sph-request-id']})"
      end

      # Calculate signature again here and we should end up to the same result
      calculated_signature = Signer.signature(
        config: @config,
        method: response.env.method.to_s.upcase,
        uri: response.env.url.path.to_s,
        headers: response.env.response_headers.select {|h,v| h.start_with? 'sph-'}, # Only sph- headers are needed for signature
        body: response.env.body
      )
      if response.env[:response_headers]['signature'] != calculated_signature
        raise Error, "signature mismatch! sph-request-id: #{response.env[:response_headers]['sph-request-id']}"
      end
    end
  end
end
