require 'spec_helper'

describe BucketsController do
  render_views

  let(:owner_token) { 'dcc7d3b5152e86064a46e4fef5160d173fe2edd1f1c9c793' }

  describe 'PUT #update' do
    let(:bucket) { Bucket.create(owner_token: owner_token) }

    it 'updates a bucket' do
      bucket_params = { 'name' => 'test123', 'response_builder' => 'response.body = "ok";' }

      put :update, token: bucket.token, bucket: bucket_params

      bucket.reload

      expect(bucket.attributes).to include(bucket_params)

      expect(response).to redirect_to(bucket_path(bucket.token))
    end
  end

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

  describe 'GET #last' do
    let(:bucket) { Bucket.create(owner_token: owner_token) }

    context 'when found' do
      let(:rack_request) { ActionController::TestRequest.new('RAW_POST_DATA' =>  '{"message":"Hello World"}') }

      before do
        stub_request(:get, 'http://example.com').
          to_return(body: '', status: 202, headers: { 'Content-Type' => 'text/plain' })

        bucket.record_request(rack_request)
      end

      it 'renders JSON' do
        get :last, token: bucket.token, format: :json

        expect(response.body).to be_present # TODO: test the contents
        expect(response).to be_ok
      end
    end

    context 'when not found' do
      it 'redirects to root' do
        get :last, token: bucket.token

        expect(response).to redirect_to(bucket_path(bucket.token))
      end

      context 'when JSON' do
        it 'renders not_found' do
          get :last, token: bucket.token, format: :json

          expect(response.status).to eq(404)
        end
      end
    end
  end

  describe 'GET #last_response' do
    let(:bucket) { Bucket.create(owner_token: owner_token) }

    context 'when found' do
      let(:rack_request) { ActionController::TestRequest.new('RAW_POST_DATA' =>  '{"message":"Hello World"}') }

      before do
        stub_request(:get, 'http://example.com').
          to_return(body: '', status: 202, headers: { 'Content-Type' => 'text/plain' })

        bucket.build_response(bucket.record_request(rack_request))
      end

      it 'renders JSON' do
        get :last_response, token: bucket.token, format: :json

        expect(response.body).to be_present # TODO: test the contents
        expect(response).to be_ok
      end
    end

    context 'when not found' do
      it 'redirects to root' do
        get :last_response, token: bucket.token

        expect(response).to redirect_to(bucket_path(bucket.token))
      end

      context 'when JSON' do
        it 'renders not_found' do
          get :last_response, token: bucket.token, format: :json

          expect(response.status).to eq(404)
        end
      end
    end
  end
end
