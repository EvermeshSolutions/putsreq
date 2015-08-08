require 'spec_helper'

RSpec.describe TrackEvent do
  describe '#call' do
    let(:bucket)  { Bucket.new token: 'super_token' }
    let(:request) { double(:request).as_null_object }

    before { stub_env('GA', 'UA-12345678-9')}

    it 'creates an event' do
      tracker = double(:tracker)

      allow(Staccato).to receive_message_chain(:tracker, :build_event).
        and_return(tracker)

      expect(tracker).to receive(:add_measurement).with(:request, token: bucket.token)
      expect(tracker).to receive(:track!)

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
