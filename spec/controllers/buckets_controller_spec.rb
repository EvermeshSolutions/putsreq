require 'spec_helper'

describe BucketsController do
  render_views

  let(:owner_token) { 'dcc7d3b5152e86064a46e4fef5160d173fe2edd1f1c9c793' }
  let(:bucket) { Bucket.create(owner_token: owner_token) }

  describe 'DELETE #clear' do
    let(:rack_request) { ActionController::TestRequest.new('RAW_POST_DATA' =>  '{"message":"Hello World"}') }

    before do
      stub_request(:get, 'http://example.com').
        to_return(body: '', status: 202, headers: { 'Content-Type' => 'text/plain' })
    end

    it 'clears history' do
      bucket.build_response(bucket.record_request(rack_request))

      expect(bucket.requests).to have(1).item
      expect(bucket.responses).to have(1).item

      delete :clear, token: bucket.token

      bucket.reload
      expect(bucket.requests).to be_empty
      expect(bucket.responses).to be_empty
    end
  end

  describe 'POST #fork' do
    it 'forks a bucket' do
      name = bucket.name
      expect {
        post :fork, token: bucket.token

        bucket2 = Bucket.last

        expect(bucket2.name).to eq "Copy of #{name}"
        expect(bucket2.fork).to eq bucket

        expect(response).to redirect_to(bucket_path(bucket2.token))
      }.to change(Bucket, :count).by(1)
    end
  end

  describe 'PUT #update' do
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
    it 'shows a bucket' do
      get :show, token: bucket.token

      expect(assigns(:bucket)).to eq(bucket)
      expect(assigns(:requests)).to eq(bucket.requests)
    end
  end

  describe 'GET #share' do
    it 'shows a bucket' do
      get :share, token: bucket.read_only_token

      expect(assigns(:bucket)).to eq(bucket)
      expect(assigns(:requests)).to eq(bucket.requests)
    end
  end

  describe 'GET #last' do
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
