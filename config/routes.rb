PutsReq::Application.routes.draw do
  root to: 'home#index'

  post 'buckets' => 'buckets#create', as: :buckets
  get ':token/inspect' => 'buckets#show', as: :bucket
  get 'readonly/:token/inspect' => 'buckets#share', as: :share_bucket
  get ':token/last' => 'buckets#last', as: :bucket_last
  get ':token/last_response' => 'buckets#last_response', as: :bucket_last_response
  put ':token/buckets' => 'buckets#update', as: :update_bucket
  match ':token' => 'buckets#record', via: :all, as: :bucket_record
end
