require 'spec_helper'

describe Bucket do
  let(:rack_request) { ActionController::TestRequest.new }

  subject { described_class.create(name: 'test123') }

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

    it 'generates a read_only_token' do
      expect(subject.read_only_token).to be_present
    end

    it { expect(subject.last_request_at).to be_nil }
  end

  describe '#name' do
    it 'returns name' do
      expect(subject.name).to eq 'test123'
    end

    context 'when name is blank' do
      subject { described_class.create }

      it 'returns token' do
        expect(subject.name).to eq subject.token
      end
    end
  end

  describe '#build_response' do
    let(:rack_request) { ActionController::TestRequest.new('RAW_POST_DATA' =>  '{"message":"Hello World"}') }

    context 'when last_response is available' do
      subject { described_class.create response_builder: %{if(last_response) { response.body = last_response.body + ' world'; } else { response.body = 'hello'; }} }

      it 'uses last_response' do
        stub_request(:get, 'http://example.com').
          to_return(body: '', status: 202, headers: { 'Content-Type' => 'text/plain' })

        2.times {
          subject.build_response(
            subject.record_request(rack_request)
          )
        }

        expect(subject.last_response.attributes).to include('body' => "hello world")
      end
    end

    context 'when forward to' do
      subject { described_class.create response_builder: %{response.status = 200; response.body = "It's me, Mario!"; request.forwardTo = 'http://example.com'} }

      it 'uses forwarded response' do
        stub_request(:get, 'http://example.com').
          to_return(body: %{It's me, Luigi!}, status: 202, headers: { 'Content-Type' => 'text/plain' })

        request = subject.record_request(rack_request)
        response = subject.build_response(request)

        expect(response.attributes).to include('status'  => 202,
                                               'body'    => "It's me, Luigi!",
                                               'headers' => { 'content-type' => ['text/plain'] })
      end
    end

    context 'when timeout' do
      subject { described_class.create response_builder: 'while(true){}' }

      it 'terminates builder' do
        request = subject.record_request(rack_request)

        response = subject.build_response(request, 0.1)

        expect(response.attributes).to include('status'  => 500,
                                               'body'    => 'Script Timed Out')
      end
    end

    context 'when response_builder is absent' do
      subject { described_class.create response_builder: nil }

      it 'uses default_response' do
        request = subject.record_request(rack_request)

        response = subject.build_response(request)

        expect(response.attributes).to include('status'  => 200,
                                               'body'    => 'ok')
      end
    end

    context 'when default response_builder' do
      it 'builds Hello World' do
        request = subject.record_request(rack_request)

        response = subject.build_response(request)

        expect(response.attributes).to include('status'  => 200,
                                               'headers' => {},
                                               'body'    => 'Hello World')
      end
    end

    context 'when error' do
      subject { described_class.create(response_builder: 'will fail') }

      it 'returns error response' do
        request = subject.record_request(rack_request)

        response = subject.build_response(request)

        expect(response.attributes).to include('status'  => 500,
                                               'headers' => { 'Content-Type' => 'text/plain' },
                                               'body'    => 'Unexpected identifier at <eval>:1:10')
      end
    end
  end

  describe '#record_request' do
    it 'copies required attributes' do
      now = Time.now
      Time.stub(now: now)

      req = subject.record_request(rack_request)

      expect(req).to be_persisted
      expect(req.attributes).to include('body'           => rack_request.body.read,
                                        'content_length' => rack_request.content_length,
                                        'request_method' => rack_request.request_method,
                                        'ip'             => rack_request.ip,
                                        'url'            => rack_request.url,
                                        'params'         => rack_request.params)

      expect(subject.last_request_at).to eq(now)
    end

    it 'skips lowercase headers (rack specific headers)' do
      rack_request.env['foo'] = 'bar'
      rack_request.env['bar'] = 'foo'

      request = subject.record_request(rack_request)

      expect(request.headers).to_not include('foo', 'bar')
    end
  end

  describe '#requests_count' do
    it 'returns the number of requests made to the bucket' do
      expect {
        subject.record_request(rack_request)
      }.to change { subject.requests_count }.from(0).to(1)
    end
  end

  pending '#last_request'
  pending '#last_response'
end
