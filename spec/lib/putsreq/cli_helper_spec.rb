require 'spec_helper'
require 'putsreq/cli_helper'

module PutsReq
  RSpec.describe CLIHelper do
    let(:token) { 'i7kOKCEEO66kR1n0ASzY' }
    let(:to) { 'http://example.com' }
    let(:local) { false }
    let(:body) { 'Hello World' }
    let(:headers) { { 'ACCEPT' => 'text/plain' } }
    let(:request_id) { 'j7kOKCEEO66kR1n0ASzY' }
    let(:request) do
      {
        '_id' => {
          '$oid' => request_id
        },
        'headers' => headers,
        'body' => body,
        'request_method' => 'get'
      }
    end

    subject { described_class.new(token, to, local) }

    describe '#subscribe_and_forward' do
      it 'subscribes and forwards' do
        expect(HTTParty).to receive(:get).with("https://putsreq.com/#{token}/last.json").and_return(
          double(code: 200, ok?: true, parsed_response: request)
        )
        expect(HTTParty).to receive(:get).with(
          "https://putsreq.com/#{token}/requests.json?last_request_id=#{request_id}"
        ).and_return(
          double(code: 200, ok?: true, parsed_response: [request])
        )
        expect(HTTParty).to receive(:get).with(to, headers: headers, body: body).and_return(OpenStruct.new(code: 200))

        expect(HTTParty).to receive(:get).with(
          "https://putsreq.com/#{token}/requests.json?last_request_id=#{request_id}"
        ).and_return(
          double(code: 200, ok?: false)
        )

        subject.subscribe_and_forward
      end

      context 'when not found' do
        it 'exits' do
          expect(HTTParty).to receive(:get).with("https://putsreq.com/#{token}/last.json").and_return(
            double(code: 200, ok?: true, parsed_response: request)
          )
          expect(HTTParty).to receive(:get).with(
            "https://putsreq.com/#{token}/requests.json?last_request_id=#{request_id}"
          ).and_return(
            double(code: 200, ok?: false)
          )
          expect(HTTParty).to_not receive(:get)

          subject.subscribe_and_forward
        end
      end
    end

    describe '#find_and_forward' do
      it 'forwards a request' do
        expect(HTTParty).to receive(:get).with(
          "https://putsreq.com/#{token}/requests/#{request_id}.json"
        ).and_return(
          double(code: 200, ok?: true, parsed_response: request)
        )
        expect(HTTParty).to receive(:get).with(to, headers: headers, body: body).and_return(OpenStruct.new(code: 200))

        subject.find_and_forward(request_id)
      end

      context 'when not found' do
        it 'does not forward' do
          id = 'j7kOKCEEO66kR1n0ASzY'
          expect(HTTParty).to receive(:get).with(
            "https://putsreq.com/#{token}/requests/#{request_id}.json"
          ).and_return(
            double(code: 200, ok?: false, parsed_response: request)
          )
          expect(HTTParty).to_not receive(:get)

          subject.find_and_forward(id)
        end
      end
    end

    describe '.valid_to?' do
      it 'is valid' do
        expect(described_class.valid_to?('nonono')).to_not be
      end

      it 'is invalid' do
        expect(described_class.valid_to?('https://putsreq.com')).to be
      end
    end

    describe '.parse_token' do
      specify do
        expect(described_class.parse_token(token)).to eq(token)
      end

      context 'when a URL' do
        specify do
          url = "https://putsreq.com/#{token}"

          expect(described_class.parse_token(url)).to eq(token)
        end
      end
    end
  end
end