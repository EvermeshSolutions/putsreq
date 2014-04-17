require 'spec_helper'

describe Request do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  let(:puts_req) { PutsReq.create }

  describe '.from_request' do
    before { post '/test' }

    it 'copies required attributes' do
      request = described_class.from_request(last_request) do |request|
        request.puts_req = puts_req
      end

      expect(request).to be_persisted
      expect(request.body).to eq last_request.body.read
      expect(request.content_length).to eq last_request.content_length
      expect(request.request_method).to eq last_request.request_method
      expect(request.ip).to eq last_request.ip
      expect(request.url).to eq last_request.url
      expect(request.params).to eq last_request.params
    end

    it 'skips lowercase headers (rack specific headers)' do
      last_request.env['foo'] = 'bar'
      last_request.env['REQUEST_METHOD'] = 'GET'

      request = described_class.from_request(last_request) do |request|
        request.puts_req = puts_req
      end

      expect(request.headers).to_not include('foo')
    end
  end
end
