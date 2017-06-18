require 'spec_helper'

RSpec.describe CreateOrRetrieveBucket do
  describe '#call' do
    specify do
      expect {
        result = described_class.call!(token: 'new_token')

        expect(result.bucket).to be
      }.to change(Bucket, :count).by(1)
    end

    context 'when existing bucket' do
      let!(:bucket) { Bucket.create }

      specify do
        expect {
          result = described_class.call!(token: bucket.token)

          expect(result.bucket).to eq(bucket)
        }.to_not change(Bucket, :count)
      end
    end
  end
end
