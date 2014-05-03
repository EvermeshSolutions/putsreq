require 'spec_helper'

describe BucketsController do
  render_views

  let(:owner_token) { 'dcc7d3b5152e86064a46e4fef5160d173fe2edd1f1c9c793' }

  describe 'POST #create' do
    it 'creates a new bucket' do
      expect {
        post :create
      }.to change(Bucket, :count).by(1)

      expect(response).to redirect_to(bucket_path(Bucket.last.token))
    end
  end

  describe 'GET #show' do
    let(:bucket) { Bucket.create(owner_token: owner_token) }

    it 'shows a bucket' do
      get :show, token: bucket.token

      expect(assigns(:bucket)).to eq(bucket)
      expect(assigns(:requests)).to eq(bucket.requests)
    end
  end
end
