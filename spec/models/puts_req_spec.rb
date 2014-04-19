require 'spec_helper'

describe PutsReq do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  subject { PutsReq.create }

  describe '#build_response' do
    before { post '/test', '{"message":"Hello World"}' }

    context 'when response_builder is absent' do
      subject { PutsReq.create response_builder: nil }

      it 'uses default_response' do
        req = subject.record_request(last_request)

        resp = subject.build_response(req)

        expect(resp).to include('status'  => 200,
                                'body'    => 'ok')
      end
    end

    context 'when default response_builder' do
      it 'builds Hello World Pablo' do
        req = subject.record_request(last_request)

        resp = subject.build_response(req)

        expect(resp).to include('status'  => 200,
                                'headers' => { 'Content-Type' => 'application/json' },
                                'body'    => { 'message' => 'Hello World Pablo' })
      end
    end

    context 'when error' do
      subject { PutsReq.create(response_builder: 'will fail') }

      it 'returns error response' do
        req = subject.record_request(last_request)

        resp = subject.build_response(req)

        expect(resp).to include('status'  => 500,
                                'headers' => { 'Content-Type' => 'text/plain' },
                                'body'    => 'Unexpected identifier at <eval>:1:10')
      end
    end
  end

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
      last_request.env['bar'] = 'foo'

      req = subject.record_request(last_request)

      expect(req.headers).to_not include('foo', 'bar')
    end
  end
end
