require 'spec_helper'

RSpec.describe Bucket do
  let(:rack_request) { ActionController::TestRequest.create({}) }

  let(:bucket_name) { 'My Bucket' }
  subject { described_class.create(name: bucket_name) }

  describe '#clear_history' do
    it 'filters history' do
      stub_request(:get, 'http://example.com')
        .to_return(body: %(It's me, Luigi!), status: 202, headers: { 'Content-Type' => 'text/plain' })

      RecordRequest.call(bucket: subject, rack_request: rack_request)

      expect(subject.requests.count).to eq 1
      expect(subject.responses.count).to eq 1

      subject.clear_history

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
    it 'returns count' do
      expect {
        Request.create(bucket: subject)
      }.to change { subject.requests_count }.from(0).to(1)
    end

    context 'when no requests' do
      it 'returns 0' do
        expect(subject.requests_count).to eq(0)
      end
    end
  end

  describe '#last_request_at' do
    it 'returns last_email_at' do
      Request.create bucket: subject
      last = Request.create bucket: subject

      expect(subject.last_request_at).to eq(last.reload.created_at)
    end

    context 'when no requests' do
      it 'returns nil' do
        expect(subject.last_request_at).to be_nil
      end
    end
  end

  describe '#first_request_at' do
    it 'returns first_email_at' do
      first = Request.create bucket: subject
      Request.create bucket: subject

      expect(subject.first_request_at).to eq(first.reload.created_at)
    end

    context 'when no requests' do
      it 'returns nil' do
        expect(subject.first_request_at).to be_nil
      end
    end
  end
end
