require 'spec_helper'

RSpec.describe CreateResponse do
  let(:rack_request) { ActionController::TestRequest.new('RAW_POST_DATA' =>  '{"message":"Hello World"}') }
  let(:bucket)       { Bucket.create(name: 'My Bucket') }
  let(:request) do
    result = CreateRequest.call(bucket: bucket, rack_request: rack_request) # stub it?
    result.request
  end

  describe '#call' do
    context 'when forward to' do
      let(:response_builder) do
        <<-EOF.strip_heredoc
          response.status = 200;
          response.body = "It's me, Mario!";
          request.forwardTo = "http://example.com";
        EOF
      end

      let(:bucket) { Bucket.create(response_builder: response_builder) }

      it 'uses forwarded response' do
        stub_request(:get, 'http://example.com')
          .to_return(body: "It's me, Luigi!", status: 202, headers: { 'Content-Type' => 'text/plain' })

        result = described_class.call(bucket: bucket, request: request)
        resp = result.response

        expect(resp.attributes).to include('status'  => 202,
                                           'body'    => "It's me, Luigi!",
                                           'headers' => { 'content-type' => 'text/plain' })
      end
    end

    context 'when timeout' do
      let(:bucket) { Bucket.create response_builder: 'while(true){}' }

      it 'terminates builder' do
        result = described_class.call(bucket: bucket, request: request)
        resp = result.response

        expect(resp.attributes).to include('status'  => 500,
                                           'body'    => 'Script Timed Out')
      end
    end

    context 'when response_builder is absent' do
      let(:bucket) { Bucket.create response_builder: nil }

      it 'uses default_response' do
        result = described_class.call(bucket: bucket, request: request)
        resp = result.response

        expect(resp.attributes).to include('status'  => 200,
                                           'body'    => 'ok')
      end
    end

    context 'when default response_builder' do
      it 'builds Hello World' do
        result = described_class.call(bucket: bucket, request: request)
        resp = result.response

        expect(resp.attributes).to include('status'  => 200,
                                           'headers' => {},
                                           'body'    => 'Hello World')
      end
    end

    context 'when error' do
      let(:bucket) { Bucket.create(response_builder: 'will fail') }

      it 'returns error response' do
        result = described_class.call(bucket: bucket, request: request)
        resp = result.response

        expect(resp.attributes).to include('status'  => 500,
                                           'headers' => { 'Content-Type' => 'text/plain' },
                                           'body'    => 'Unexpected identifier at <eval>:1:10')
      end
    end
  end
end
