require 'spec_helper'

RSpec.describe Bucket do
  let(:rack_request) { ActionController::TestRequest.new }

  let(:bucket_name) { 'My Bucket' }
  subject { described_class.create(name: bucket_name) }

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

  describe '#clear_history' do
    it 'filters history' do
      stub_request(:get, 'http://example.com').
        to_return(body: %{It's me, Luigi!}, status: 202, headers: { 'Content-Type' => 'text/plain' })

      RecordRequest.call(bucket: subject, rack_request: rack_request)

      expect(subject.requests.count).to eq 1
      expect(subject.responses.count).to eq 1

      subject.update_attribute :history_start_at, Time.now

      expect(subject.requests.count).to eq 0
      expect(subject.responses.count).to eq 0

      RecordRequest.call(bucket: subject, rack_request: rack_request)

      expect(subject.requests.count).to eq 1
      expect(subject.responses.count).to eq 1
    end
  end

  describe '.create' do
    it 'generates a token' do
      expect(subject.token).to be_present
    end

    it { expect(subject.last_request_at).to be_nil }
  end

  describe '#name' do
    it 'returns name' do
      expect(subject.name).to eq bucket_name
    end

    context 'when name is blank' do
      subject { described_class.create }

      it 'returns token' do
        expect(subject.name).to eq subject.token
      end
    end
  end

  describe '#requests_count' do
    it 'returns the number of requests made to the bucket' do
      expect {
        RecordRequest.call(bucket: subject, rack_request: rack_request)
      }.to change { subject.requests_count }.from(0).to(1)
    end
  end

  pending '#last_request'
  pending '#last_response'
end
