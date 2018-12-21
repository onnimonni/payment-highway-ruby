require 'spec_helper'

describe PaymentHighway::BatchReport do

  before(:each) do
    @now = Time.parse('2018-11-20 12:55:15')
    @request_id = '30cbbf47-12a1-4e02-875a-69eaa65c23a1'
    @data = {"settlements"=>[], "result"=>{"code"=>100, "message"=>"OK"}}
    @config = PaymentHighway::Config.new(
      account: 'test',
      merchant: 'test_merchantId',
      key: 'testKey',
      secret: 'testSecret'
    )
    @report_url = "#{@config.service}/report/batch/20181120"
    # Mock uuid so that we will get the same value from mocked server
    allow(SecureRandom).to receive(:uuid).and_return(@request_id)

    # Mock time because otherwise signature calculation won't work
    allow(Time).to receive(:now) { @now }

    @valid_headers = {
      'sph-request-id': @request_id,
      'sph-timestamp': Time.now.utc.strftime('%FT%TZ'),
      'sph-response-id': '0bcae09d-cd72-4768-bb51-80962e96ac52',
      'signature': 'SPH1 testKey bd68d2d5453541c0c0deefc008df0d1eb0a0544590c60c1af7ef0e41b82c7802'
    }
  end

  it "should throw exception from missing headers empty reports" do
    stub_request(:get, @report_url).to_return( body: @data.to_json, headers: {})

    expect {
      described_class.new(config: @config, date: @now.to_date)
    }.to raise_error( PaymentHighway::Error,
      'Mandatory headers ["sph-timestamp", "sph-request-id", "sph-response-id", "signature"] are missing from response'
    )
  end

  it "should throw exception from mismatching request id" do
    stub_request(:get, @report_url).to_return( body: @data.to_json, headers: @valid_headers.merge({
      'sph-request-id': '8cc1167b-eaf3-4394-893d-9e02f825311a'
    }))

    expect {
      described_class.new(config: @config, date: @now.to_date)
    }.to raise_error( PaymentHighway::Error, /request-id mismatch!/)
  end

  it "should throw exception from broken signature" do
    stub_request(:get, @report_url).
      to_return( body: @data.to_json, headers: @valid_headers.merge({
      'signature': 'SPH1 testKey 724651aab8aa41f9402b9de9dbfade5ac392b93f141a77b82df8d8e91d182e32'
    }))

    expect {
      described_class.new(config: @config, date: @now.to_date)
    }.to raise_error( PaymentHighway::Error, /signature mismatch!/)
  end

  it "should return empty reports on valid response" do
    # Stub the request to batch reports
    stub_request(:get, @report_url).
      to_return(body: @data.to_json, headers: @valid_headers)

    report = described_class.new(config: @config, date: @now.to_date)
    expect(report.settlements).to eq(@data['settlements'])
    expect(report.result).to eq(@data['result'])

    expect(report.url).to eq(@report_url)
    expect(report.request_id).to eq(@request_id)
    expect(report.response_id).to eq(@valid_headers[:'sph-response-id'])
  end

  it "should return empty reports even without merchant" do
    # Stub the request to batch reports
    stub_request(:get, @report_url).
      to_return(body: @data.to_json, headers: @valid_headers)

    conf = PaymentHighway::Config.new(
      account: 'test',
      key: 'testKey',
      secret: 'testSecret'
    )
    result = described_class.new(config: conf, date: @now.to_date)
    expect(result.settlements).to eq(@data['settlements'])
    expect(result.result).to eq(@data['result'])
  end
end
