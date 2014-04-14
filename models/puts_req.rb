class PutsReq
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :requests, dependent: :delete

  field :response_builder
end
