class CreateResponse
  include Interactor

  delegate :bucket, :request, :built_response, to: :context

  def call
    built_response['request'] = request

    context.response = bucket.responses.create(built_response)
  end
end
