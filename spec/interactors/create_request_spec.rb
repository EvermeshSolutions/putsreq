require 'spec_helper'

RSpec.describe CreateRequest do
  let(:rack_request) { ActionController::TestRequest.new }
  let(:bucket)       { Bucket.create(name: 'My Bucket') }

  describe '#call' do
    it 'copies required attributes' do
      now = Time.now
      allow(Time).to receive(:now) { now }

      result = described_class.call(bucket: bucket, rack_request: rack_request)
      req = result.request

      expect(req).to be_persisted
      expect(req.attributes).to include(
        'body'           => rack_request.body.read,
        'content_length' => rack_request.content_length,
        'request_method' => rack_request.request_method,
        'ip'             => rack_request.ip,
        'url'            => rack_request.url
      )

      expect(result.params).to eq(rack_request.params)
    end

    it 'skips lowercase headers (rack specific headers)' do
      rack_request.env['foo'] = 'bar'
      rack_request.env['bar'] = 'foo'

      result = described_class.call(bucket: bucket, rack_request: rack_request)
      req = result.request

      expect(req.headers).to_not include('foo', 'bar')
    end
  end
end
