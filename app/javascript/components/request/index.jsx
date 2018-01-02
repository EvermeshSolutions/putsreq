import React, { Component } from 'react'
import { connect } from 'react-redux'
import Header from './Header'
import Response from './Response'
import PropTypes from 'prop-types'

export default class Request extends Component {
  render() {
    if(!this.props.id) {
      return (
        <p>No requests found</p>
      )
    }

    return (
      <div className="panel-group request-show" id="accordion" role="tablist" aria-multiselectable="true">
        <Header headers_as_string={this.props.headers_as_string} time_ago_in_words={this.props.time_ago_in_words} created_at={this.props.created_at} />
        <div className="panel panel-default">
          <div className="panel-heading" role="tab" id="headingTwo">
            <h4 className="panel-title">
              <a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo" aria-expanded="true" aria-controls="collapseTwo">
                {this.props.request_method} {this.props.path}
              </a>
            </h4>
          </div>
          <div id="collapseTwo" className="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingTwo">
            <div className="panel-body">
              <pre>{this.props.request_body_as_string}</pre>
            </div>
          </div>
        </div>
        <Response response_body_as_string={this.props.response_body_as_string} />
      </div>
    )
  }
}

Response.propTypes = {
  request_method: PropTypes.string,
  path: PropTypes.string,
  request_body_as_string: PropTypes.string,
  response_body_as_string: PropTypes.string,
  created_at: PropTypes.string,
  id: PropTypes.string,
  time_ago_in_words: PropTypes.string,
  headers_as_string: PropTypes.string
}
