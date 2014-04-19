require 'sinatra/base'
require 'sinatra/multi_route'
require 'v8'
require 'erb'
require 'mongoid'
require 'therubyracer'
require 'active_support/all'
require 'httparty'

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

    redirect "/#{puts_req.token}/inspect"
  end

  # Update Response Builder
  post '/:token/response_builder' do |token|
    puts_req = PutsReq.find_by_token(token)

    puts_req.update_attribute :response_builder, params[:response_builder]

    redirect "/#{puts_req.token}/inspect"
  end

  # Post sample request
  post '/:token/post' do |token|
    puts_req = PutsReq.find_by_token(token)

    HTTParty.post("#{request.url.gsub(request.path, '')}/#{puts_req.token}",
                  body: { message: 'Hello World' }.to_json,
                  headers: { 'Content-Type' => 'application/json' })

    redirect "/#{puts_req.token}/inspect"
  end

  get '/:token/inspect' do |token|
    puts_req = PutsReq.find_by_token(token)

    erb :show, locals: { puts_req: puts_req }
  end

  get '/:token/last' do |token|
    puts_req = PutsReq.find_by_token(token)

    content_type :json

    last_req = puts_req.requests.first

    not_found unless last_req

    return { body: last_req.body, headers: last_req.headers, created_at: last_req.created_at }.to_json
  end

  get '/:token/last_response' do |token|
    puts_req = PutsReq.find_by_token(token)

    content_type :json

    last_resp = puts_req.responses.first

    not_found unless last_resp

    return { status: last_resp.status, body: last_resp.body, headers: last_resp.headers, created_at: last_resp.created_at }.to_json
  end

  route :get, :post, :put, :patch, :delete, '/:token' do |token|
    puts_req = PutsReq.find_by_token(token)

    req  = puts_req.record_request(request)
    resp = puts_req.build_response(req)

    status resp.status
    headers resp.headers

    resp.body_to_s
  end
end
