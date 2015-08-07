class RecordRequest
  include Interactor::Organizer

  organize CreateRequest, EvalResponseBuilder, ForwardRequest, CreateResponse, NotifyCount, TrackPageView
end
