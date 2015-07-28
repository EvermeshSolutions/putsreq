require 'spec_helper'

RSpec.describe UpdateBucketStats do
  let(:bucket) { Bucket.create(name: 'My Bucket') }

  before do
    now = Time.now
    allow(Time).to receive(:now) { now }
  end

  describe '#call' do
    it 'update all stats' do
      described_class.call(bucket: bucket)

      expect(bucket.attributes).to include('requests_count'   => 1,
                                           'first_request_at' => Time.now,
                                           'last_request_at'  => Time.now)
    end

    context 'when existing requests' do
      before do
        described_class.call(bucket: bucket)
      end

      it 'updates updatable stats' do
        old_now = Time.now
        new_now = old_now + 60
        allow(Time).to receive(:now) { new_now }

        described_class.call(bucket: bucket)

        expect(bucket.attributes).to include('requests_count'   => 2,
                                             'first_request_at' => old_now,
                                             'last_request_at'  => new_now)
      end
    end
  end
end
