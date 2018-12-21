# coding: utf-8
lib = File.expand_path(File.join(__dir__,'lib'))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "payment_highway/version"

Gem::Specification.new do |s|
  s.name        = 'payment-highway'
  s.version     = PaymentHighway::VERSION
  s.summary     = "Hola!"
  s.description = "Custom payments for your custom app. Api client for Payment Highway"
  s.authors     = ['Payment Highway']
  s.email       = 'support@paymenthighway.fi'

  s.homepage    = 'https://github.com/paymenthighway/paymenthighway-rb'
  s.license     = 'MIT'

  s.add_dependency("faraday", "~> 0.15")
  s.add_dependency("openssl")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']
end
