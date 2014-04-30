require 'spec_helper'

describe Bucket do
  let(:last_request) { ActionController::TestRequest.new }

  subject { described_class.create }

  describe '.find_by_token' do
    it 'finds document' do
      document = described_class.find_by_token(subject.token)

      expect(document.id).to eq subject.id
    end

    context 'when not found' do
      it 'returns nil' do
        document = described_class.find_by_token('not found')

        expect(document).to be_nil
      end
    end
  end

  describe '.create' do
    it 'generates a token' do
      expect(subject.token).to be_present
    end
  end

  describe '#build_response' do
    let(:last_request) { ActionController::TestRequest.new('RAW_POST_DATA' =>  '{"message":"Hello World"}') }

    context 'when forward to' do
      subject { described_class.create response_builder: %{response.status = 200; response.body = "It's me, Mario!"; request.forwardTo = 'http://example.com'} }

      it 'uses forwarded response' do
        stub_request(:get, 'http://example.com').
          to_return(body: %{It's me, Luigi!}, status: 202, headers: { 'Content-Type' => 'text/plain' })

        req = subject.record_request(last_request)

        resp = subject.build_response(req)

        expect(resp.attributes).to include('status'  => 202,
                                           'body'    => "It's me, Luigi!",
                                           'headers' => { 'content-type' => ['text/plain'] })
      end
    end

    context 'when timeout' do
      subject { described_class.create response_builder: 'while(true){}' }

      it 'terminates builder' do
        req = subject.record_request(last_request)

        resp = subject.build_response(req, 0.1)

        expect(resp.attributes).to include('status'  => 500,
                                           'body'    => 'Script Timed Out')
      end
    end

    context 'when response_builder is absent' do
      subject { described_class.create response_builder: nil }

      it 'uses default_response' do
        req = subject.record_request(last_request)

        resp = subject.build_response(req)

        expect(resp.attributes).to include('status'  => 200,
                                           'body'    => 'ok')
      end
    end

    context 'when default response_builder' do
      it 'builds Hello World Pablo' do
        req = subject.record_request(last_request)

        resp = subject.build_response(req)

        expect(resp.attributes).to include('status'  => 200,
                                           'headers' => { 'Content-Type' => 'application/json' },
                                           'body'    => { 'message' => 'Hello World Pablo' })
      end
    end

    context 'when error' do
      subject { described_class.create(response_builder: 'will fail') }

      it 'returns error response' do
        req = subject.record_request(last_request)

        resp = subject.build_response(req)

        expect(resp.attributes).to include('status'  => 500,
                                           'headers' => { 'Content-Type' => 'text/plain' },
                                           'body'    => 'Unexpected identifier at <eval>:1:10')
      end
    end
  end

  describe '#record_request' do
    it 'copies required attributes' do
      req = subject.record_request(last_request)

      expect(req).to be_persisted
      expect(req.attributes).to include('body'           => last_request.body.read,
                                        'content_length' => last_request.content_length,
                                        'request_method' => last_request.request_method,
                                        'ip'             => last_request.ip,
                                        'url'            => last_request.url,
                                        'params'         => last_request.params)
    end

    it 'skips lowercase headers (rack specific headers)' do
      last_request.env['foo'] = 'bar'
      last_request.env['bar'] = 'foo'

      req = subject.record_request(last_request)

      expect(req.headers).to_not include('foo', 'bar')
    end
  end

  pending '#last_req'
  pending '#last_resp'
end
