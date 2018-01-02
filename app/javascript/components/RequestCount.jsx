import React, { Component } from 'react'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'

class RequestCount extends Component {
  render() {
    return (
      <h3>{this.props.requests_count || 0}</h3>
    )
  }
}

RequestCount.propTypes = {
  requests_count: PropTypes.number
}

const mapStateToProps = (state) => ({
  requests_count: state.bucket.requests_count
})

export default connect(mapStateToProps)(RequestCount)
