import React from 'react'
import { connect } from 'react-redux'

class RequestCount extends React.Component {
  render() {
    return (
      <h3>{this.props.requests_count || 0}</h3>
    )
  }
}

const mapStateToProps = (state) => ({
  requests_count: state.bucket.requests_count
})

export default connect(mapStateToProps)(RequestCount)
