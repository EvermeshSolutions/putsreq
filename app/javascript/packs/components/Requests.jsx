import React from 'react'
import { fetchBucket } from '../actions/requests'


export default class Requests extends React.Component {
  componentWillMount() {
    fetchBucket()
  }

  render() {
    return (
      <div className="row">
        <div className="col-md-6">
          if bucket.first_request_at
          <p>
            <em>First request at:  bucket.first_request_at <br />
              Last request at:  bucket.last_request_at <br />
              if bucket.last_request_at - bucket.first_request_at > 0
              From first to last:  distance_of_time_in_words bucket.first_request_at, bucket.last_request_at, include_seconds: true <br />
              end
              if requests.any?
              Request ID:  link_to requests.first.id, request_path(id: requests.first.id, format: :json)
              end
            </em>
          </p>
          end
        </div>
        <div className="col-md-6"></div>
      </div>
    )
  }
}
