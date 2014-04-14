class Request
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :puts_req

  # http://www.sinatrarb.com/intro#Accessing%20the%20Request%20Object
  field :body
  field :headers, type: Hash

  field :response

  default_scope order_by(:created_at.desc)
end
