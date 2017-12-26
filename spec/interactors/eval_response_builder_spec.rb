require 'spec_helper'

RSpec.describe EvalResponseBuilder do
  let(:rack_request) { ActionController::TestRequest.create('RAW_POST_DATA' =>  '{"message":"Hello World"}') }
  let(:request_ctx) { CreateRequest.call(bucket: bucket, rack_request: rack_request) }

  describe '#call' do
    context 'when timeout' do
      let(:bucket) { Bucket.create response_builder: 'while(true){}' }

      it 'terminates builder' do
        result = described_class.call(request_ctx)
        resp = result.built_response

        expect(resp).to eq('status'  => 500,
                           'headers' => { 'Content-Type' => 'text/plain' },
                           'body'    => 'Script Timed Out')
      end
    end

    context 'when response_builder is absent' do
      let(:bucket) { Bucket.create response_builder: nil }

      it 'uses default_response' do
        result = described_class.call(request_ctx)
        resp = result.built_response

        expect(resp).to eq('status'  => 200,
                           'headers' => {},
                           'body'    => 'ok')
      end
    end

    context 'when default response_builder' do
      let(:bucket) { Bucket.create }

      it 'builds Hello World' do
        result = described_class.call(request_ctx)
        resp = result.built_response

        expect(resp).to eq('status'  => 200,
                           'headers' => {},
                           'body'    => 'Hello World')
      end
    end

    context 'when error' do
      let(:bucket) { Bucket.create(response_builder: 'will fail') }

      it 'returns error response' do
        result = described_class.call(request_ctx)
        resp = result.built_response

        expect(resp).to eq('status'  => 500,
                           'headers' => { 'Content-Type' => 'text/plain' },
                           'body'    => 'Unexpected identifier at <eval>:1:10')
      end
    end
  end
end
