import React from 'react'
import { connect } from 'react-redux'

class RequestCount extends React.Component {
  render() {
    if(!this.props.requests_count) { return null }

    return (
      <h3>{this.props.requests_count}</h3>
    )
  }
}

const mapStateToProps = (state) => ({
  requests_count: state.bucket.requests_count
})

export default connect(mapStateToProps)(RequestCount)
