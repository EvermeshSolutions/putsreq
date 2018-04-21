require 'spec_helper'

RSpec.describe BucketsController, type: :controller do
  render_views

  let(:owner_token) { 'dcc7d3b5152e86064a46e4fef5160d173fe2edd1f1c9c793' }
  let(:bucket) { Bucket.create(owner_token: owner_token) }

  before do
    request.cookies[:owner_token] = bucket.owner_token
  end

  describe 'DELETE #clear' do
    let(:rack_request) { ActionController::TestRequest.create('RAW_POST_DATA' => '{"message":"Hello World"}') }

    before do
      stub_request(:get, 'http://example.com')
        .to_return(body: '', status: 202, headers: { 'Content-Type' => 'text/plain' })
    end

    specify do
      RecordRequest.call(bucket: bucket, rack_request: rack_request)

      expect(bucket.requests.count).to eq(1)
      expect(bucket.responses.count).to eq(1)

      delete :clear, params: { token: bucket.token }

      bucket.reload

      expect(bucket.requests).to be_empty
      expect(bucket.responses).to be_empty
    end
  end

  describe 'POST #fork' do
    specify do
      name = bucket.name
      expect {
        post :fork, params: { token: bucket.token }

        expect(bucket.forks.count).to eq 1

        bucket2 = bucket.forks.first

        expect(bucket2.name).to eq "Copy of #{name}"
        expect(bucket2.fork).to eq bucket

        expect(response).to redirect_to(bucket_path(bucket2.token))
      }.to change(Bucket, :count).by(1)
    end
  end

  describe 'PUT #update' do
    specify do
      bucket_params = { 'name' => 'test123', 'response_builder' => 'response.body = "ok";' }

      put :update, params: { token: bucket.token, bucket: bucket_params }

      bucket.reload

      expect(bucket.attributes).to include(bucket_params)

      expect(response).to redirect_to(bucket_path(bucket.token))
    end
  end

  describe 'POST #create' do
    specify do
      expect {
        post :create
      }.to change(Bucket, :count).by(1)

      expect(response).to redirect_to(bucket_path(Bucket.order(:id.asc).last.token))
    end
  end

  describe 'GET #show' do
    specify do
      get :show, params: { token: bucket.token }

      expect(assigns(:_bucket)).to eq(bucket)
    end

    context 'when not found' do
      it 'creates a new bucket' do
        token = 'not-found'
        expect {
          get :show, params: { token: token }

          expect(assigns(:_bucket)).to eq(Bucket.find_by(token: token))
        }.to change(Bucket, :count).by(1)
      end
    end
  end

  describe 'GET #last' do
    context 'when found' do
      context 'when JSON' do
        let(:rack_request) { ActionController::TestRequest.create('RAW_POST_DATA' => '{"message":"Hello World"}') }

        before do
          stub_request(:get, 'http://example.com')
            .to_return(body: '', status: 202, headers: { 'Content-Type' => 'text/plain' })

          RecordRequest.call(bucket: bucket, rack_request: rack_request)
        end

        specify do
          get :last, params: { token: bucket.token }, format: :json

          expect(response.body).to be_present # TODO: test the contents
          expect(response).to be_ok
        end
      end
    end

    context 'when not found' do
      specify do
        get :last, params: { token: bucket.token }

        expect(response).to redirect_to(bucket_path(bucket.token))
      end

      context 'when JSON' do
        specify do
          get :last, params: { token: bucket.token }, format: :json

          expect(response.status).to eq(404)
        end
      end
    end
  end

  describe 'GET #last_response' do
    context 'when found' do
      context 'when JSON' do
        let(:rack_request) { ActionController::TestRequest.create('RAW_POST_DATA' => '{"message":"Hello World"}') }

        before do
          stub_request(:get, 'http://example.com')
            .to_return(body: '', status: 202, headers: { 'Content-Type' => 'text/plain' })

          RecordRequest.call(bucket: bucket, rack_request: rack_request)
        end

        specify do
          get :last_response, params: { token: bucket.token }, format: :json

          expect(response.body).to be
          expect(response).to be_ok
        end
      end
    end

    context 'when not found' do
      specify do
        get :last_response, params: { token: bucket.token }

        expect(response).to redirect_to(bucket_path(bucket.token))
      end

      context 'when JSON' do
        specify do
          get :last_response, params: { token: bucket.token }, format: :json

          expect(response.status).to eq(404)
        end
      end
    end
  end
end
