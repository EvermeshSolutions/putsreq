import React from 'react'
import { connect } from 'react-redux'
import Requests from './Requests'
import { fetchBucket } from '../actions/bucket'

class Bucket extends React.Component {
  componentWillMount() {
    fetchBucket()
  }

  renderFirstRequest() {
    if(!this.props.bucket.first_request_at) { return }

    return (
      <p>
        <em>
          First request at: {this.props.bucket.first_request_at} <br />
          Last request at: {this.props.bucket.last_request_at} <br />
        </em>
      </p>
    )
  }

  render() {
    return (
      <div>
        <div className="row">
          <div className="col-md-6">
            {this.renderFirstRequest()}
          </div>
          <div className="col-md-6"></div>
        </div>
        <Requests {...this.props} />
      </div>
    )
  }
}

const mapStateToProps = (state) => ({
  bucket: state.bucket
})


const mapDispatchToProps = {}

export default connect(mapStateToProps, mapDispatchToProps)(Bucket)
