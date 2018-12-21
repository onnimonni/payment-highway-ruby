module PaymentHighway
  class Signer
    def self.signature(config:, method:, uri:, headers:, body: "")
      payload = ([method, uri] + Hash[headers.sort].map{|k,v| "#{k}:#{v}"} + [body]).join("\n")
      hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, config.secret, payload)
      "SPH1 #{config.key} #{hmac}"
    end
  end
end
