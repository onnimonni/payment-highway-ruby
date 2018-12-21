module PaymentHighway
  class Config
    attr_accessor :account, :merchant, :key, :secret, :service, :version
    def initialize(
      account:,
      key:,
      secret:,
      merchant: nil, # This is optional only and it's used if account has sub merchant
      service: 'https://v1.api.paymenthighway.io',
      version: PaymentHighway::API_VERSION
    )
      @account = account
      @merchant = merchant
      @key = key
      @secret = secret
      @service = service
      @version = version
    end
  end
end
