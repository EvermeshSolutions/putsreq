PutsReq::Application.routes.draw do
  devise_for :users

  root to: 'home#index'

  post 'buckets' => 'buckets#create', as: :buckets
  get ':token/inspect' => 'buckets#show', as: :bucket
  get ':token/last' => 'buckets#last', as: :bucket_last
  get ':token/last_response' => 'buckets#last_response', as: :bucket_last_response
  put ':token/buckets' => 'buckets#update', as: :update_bucket
  match ':token' => 'buckets#record', via: :all, as: :bucket_record
  delete ':token/delete' => 'buckets#destroy', as: :bucket_destroy
  delete ':token/clear' => 'buckets#clear', as: :bucket_clear
  post ':token/fork' => 'buckets#fork', as: :bucket_fork
end
