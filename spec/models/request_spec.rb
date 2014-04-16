require 'spec_helper'

describe Request do
  let(:puts_req) { PutsReq.create }
  let(:rack_request) { double(Rack::Request,
                              body: double(StringIO, read: 'ok'),
                              content_length: '25',
                              request_method: 'POST',
                              ip: '127.0.0.1',
                              url: 'http://example.com',
                              params: { 'foo' => 'bar' },
                              env: { 'CONTENT_TYPE' => 'text/plain' }) }

  describe '.from_request' do
    it 'copies required attributes' do
      request = described_class.from_request(rack_request) do |request|
        request.puts_req = puts_req
      end

      expect(request).to be_persisted
      expect(request.body).to eq rack_request.body.read
      expect(request.content_length).to eq rack_request.content_length
      expect(request.request_method).to eq rack_request.request_method
      expect(request.ip).to eq rack_request.ip
      expect(request.url).to eq rack_request.url
      expect(request.headers).to eq rack_request.env
      expect(request.params).to eq rack_request.params
    end

    it 'skips lowercase headers (rack specific headers)' do
      rack_request.env['foo'] = 'bar'
      rack_request.env['REQUEST_METHOD'] = 'GET'

      request = described_class.from_request(rack_request) do |request|
        request.puts_req = puts_req
      end

      expect(request.headers).to eq('CONTENT_TYPE' => 'text/plain', 'REQUEST_METHOD' => 'GET')
    end
  end
end
