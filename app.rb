require 'sinatra/base'
require 'sinatra/multi_route'
require 'v8'
require 'erb'
require 'mongoid'
require 'therubyracer'
require 'active_support/all'

Dir['./models/*.rb'].each &method(:load)

class PutsReqApp < Sinatra::Base
  register Sinatra::MultiRoute

  set :public_folder, File.dirname(__FILE__) + '/static'

  configure do
    Mongoid.load!('./config/mongoid.yml')
  end

  get '/' do
    erb :index
  end

  # Create new PutsReq
  post '/' do
    puts_req = PutsReq.create

    redirect "/#{puts_req.id}/inspect"
  end

  # Update Response Builder
  post '/:id/response_builder' do |id|
    puts_req = PutsReq.find(id)

    puts_req.update_attribute :response_builder, params[:response_builder]

    redirect "/#{puts_req.id}/inspect"
  end

  get '/:id/inspect' do |id|
    puts_req = PutsReq.find(id)

    erb :show, locals: { puts_req: puts_req }
  end

  get '/:id/last' do |id|
    puts_req = PutsReq.find(id)

    content_type :json

    last_req = puts_req.requests.first

    not_found unless last_req

    return { body: last_req.body, headers: last_req.headers, created_at: last_req.created_at }.to_json
  end

  get '/:id/last_response' do |id|
    puts_req = PutsReq.find(id)

    content_type :json

    last_resp = puts_req.responses.first

    not_found unless last_resp

    return { status: last_resp.status, body: last_resp.body, headers: last_resp.headers, created_at: last_resp.created_at }.to_json
  end

  route :get, :post, :put, :patch, :delete, '/:id' do |id|
    puts_req = PutsReq.find(id)

    req  = puts_req.record_request(request)
    resp = puts_req.build_response(req)

    status resp.status
    headers resp.headers

    resp.body.is_a?(Hash) ? resp.body.to_json : resp.body.to_s
  end
end
