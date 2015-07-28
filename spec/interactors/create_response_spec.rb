require 'spec_helper'

RSpec.describe CreateResponse do
  let(:rack_request) { ActionController::TestRequest.new('RAW_POST_DATA' =>  '') }
  let(:bucket)       { Bucket.create(name: 'My Bucket') }

  let(:request) do
    result = CreateRequest.call(bucket: bucket, rack_request: rack_request) # stub it?
    result.request
  end

  describe '#call' do
  end
end
