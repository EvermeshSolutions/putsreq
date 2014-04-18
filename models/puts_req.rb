class PutsReq
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :requests, dependent: :delete

  field :response_builder, default: -> { default_response_builder }

  private

  def default_response_builder
    %{response.code = 200;
response.headers['Content-Type'] = 'application/json';

// response.body = "{ message: 'Hello World' }"
var parsedBody = JSON.parse(request.body);

response.body = { message: parsedBody.message + ' Pablo' };}
  end
end
