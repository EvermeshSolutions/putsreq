class RecordRequest
  include Interactor::Organizer

  organize CreateRequest, EvalResponseBuilder, ForwardRequest, CreateResponse, Track
end
