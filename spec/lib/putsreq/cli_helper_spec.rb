require 'spec_helper'
require 'putsreq/cli_helper'

module PutsReq
  RSpec.describe CLIHelper do
    describe '.valid_to?' do
      it 'is valid' do
        expect(described_class.valid_to?('nonono')).to_not be
      end

      it 'is invalid' do
        expect(described_class.valid_to?('https://putsreq.com')).to be
      end
    end

    describe '.parse_token' do
      let(:token) { 'i7kOKCEEO66kR1n0ASzY' }

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