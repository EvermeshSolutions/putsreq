require 'spec_helper'

RSpec.describe TrackPageView do
  describe '#call' do
    let(:bucket)  { Bucket.new token: 'super_token' }
    let(:request) { double(:request).as_null_object }

    before { stub_env('GA', 'UA-12345678-9')}

    it 'creates a page view' do
      tracker = double(:tracker)

      allow(Staccato).to receive(:tracker).
        and_return(tracker)

      expect(tracker).to receive(:pageview).with(title: bucket.token)

      described_class.call bucket: bucket, rack_request: request
    end

    context 'when GA is absent' do
      it 'does nothing' do
        expect(Staccato).to_not receive(:tracker)
        described_class.call
      end
    end
  end
end
