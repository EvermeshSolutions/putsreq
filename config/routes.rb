PutsReq::Application.routes.draw do
  root to: 'home#index'

  post 'buckets' => 'buckets#create', as: :buckets
  get ':token/inspect' => 'buckets#show', as: :bucket
  get ':token/last' => 'buckets#last', as: :bucket_last
  get ':token/last_response' => 'buckets#last_response', as: :bucket_last_response
  patch ':token/response_builder' => 'buckets#response_builder', as: :bucket_response_builder
  match ':token' => 'buckets#record', via: :all, as: :bucket_record
end
