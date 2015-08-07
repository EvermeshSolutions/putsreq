require 'spec_helper'

RSpec.describe ForwardRequest do
  let(:forward_url) { 'http://example.com' }
  let(:built_request) { { 'forwardTo' => forward_url, 'request_method' => 'GET' } }

  describe '#call' do
    it 'updates built_response' do
      stub_request(:get, 'http://example.com')
        .to_return(body: "It's me, Luigi!", status: 202, headers: { 'Content-Type' => 'text/plain' })

      result = described_class.call(built_request: built_request)
      resp = result.built_response

      expect(resp).to include('status'  => 202,
                              'body'    => "It's me, Luigi!",
                              'headers' => { 'content-type' => 'text/plain' })
    end

    context 'when forward raises an error' do
      it 'updates built_response' do
        allow(HTTParty).to receive(:get).and_raise('error error')

        result = described_class.call(built_request: built_request)
        resp = result.built_response

        expect(resp).to include('status'  => 500,
                                'body'    => 'error error',
                                'headers' => { 'Content-Type' => 'text/plain' })
      end
    end

    context 'when built_response is nil' do
      it 'skips forwarding' do
        built_response = { 'status' => 200 }
        result = described_class.call(built_request: nil, built_response: built_response)

        expect(result.built_response).to eq(built_response)
      end
    end
  end
end
