require 'spec_helper'

describe PutsReq do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  subject { PutsReq.create }

  describe '#record_request' do
    before { post '/test' }

    it 'copies required attributes' do
      req = subject.record_request(last_request)

      expect(req).to be_persisted
      expect(req.body).to eq last_request.body.read
      expect(req.content_length).to eq last_request.content_length
      expect(req.request_method).to eq last_request.request_method
      expect(req.ip).to eq last_request.ip
      expect(req.url).to eq last_request.url
      expect(req.params).to eq last_request.params
    end

    it 'skips lowercase headers (rack specific headers)' do
      last_request.env['foo'] = 'bar'
      last_request.env['REQUEST_METHOD'] = 'GET'

      req = subject.record_request(last_request)

      expect(req.headers).to_not include('foo')
    end
  end
end
