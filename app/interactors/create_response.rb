class CreateResponse
  include Interactor

  def call
    built_response['request'] = context.request

    context.response = bucket.responses.create(built_response)
  end

  private

  def bucket
    context.bucket
  end

  def built_response
    context.built_response
  end
end
