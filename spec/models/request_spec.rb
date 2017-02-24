require 'spec_helper'

RSpec.describe Request do
  describe '#path' do
    let(:path) { '/12345?name=test' }

    it 'returns path' do
      subject.url = "https://putsreq.com#{path}"

      expect(subject.path).to eq path
    end

    context 'when domain with port' do
      it 'returns path' do
        subject.url = "http://localhost:3000#{path}"

        expect(subject.path).to eq path
      end
    end
  end
end
