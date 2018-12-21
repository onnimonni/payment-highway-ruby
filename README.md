# Payment Highway Ruby Library

This gem is ruby api client for Payment Highway

## Examples
### Batch Report fetching
You can find this in api documentation too: https://dev.paymenthighway.io/#daily-batch-report

```ruby
config = PaymentHighway::Config.new(
  account: 'test',
  merchant: 'test_merchantId',
  key: 'testKey',
  secret: 'testSecret',
   # Testing environment, remove this to use production
  service: 'https://v1-hub-staging.sph-test-solinor.com'
)

report = PaymentHighway::BatchReport.new(
  config: config,
  date: Date.today
)

puts report.settlements.inspect
```

## TODO
Currently only batch reports are working

## License
MIT
