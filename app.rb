require 'sinatra/base'
require 'sinatra/multi_route'
require 'v8'
require 'erb'
require 'mongoid'
require 'therubyracer'

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

  post '/:id/response_builder' do |id|
    puts_req = PutsReq.find(id)

    puts_req.update_attribute :response_builder, params[:response_builder]

    redirect "/#{puts_req.id}/inspect"
  end

  get '/:id/inspect' do |id|
    puts_req = PutsReq.find(id)

    erb :show, locals: { request: request, puts_req: puts_req }
  end

  get '/:id/last' do |id|
    puts_req = PutsReq.find(id)

    content_type :json

    last_req = puts_req.requests.first # default_scope created_at.asc

    return { body: last_req.body, headers: last_req.headers, created_at: last_req.created_at }.to_json
  end

  route :get, :post, :put, :patch, :delete, '/:id' do |id|
    puts_req = PutsReq.find(id)

    req = puts_req.record_request(request)

    return '' unless puts_req.response_builder

    context = V8::Context.new timeout: 10
    context['response'] = { code: 200, headers: {}, body: 'ok' }
    context['request']  = { body: req.body, headers: req.headers }
    context.eval(puts_req.response_builder.to_s)
    resp = context.eval('JSON.stringify(response)')

    resp = JSON.parse(resp)

    req.update_attribute :response, resp

    status resp['code']
    headers resp['headers']

    if resp['body'].is_a? Hash
      resp['body'].to_json
    else
      resp['body'].to_s
    end
  end
end
