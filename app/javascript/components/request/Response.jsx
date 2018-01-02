import React, { Component } from 'react'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'

export default class Response extends Component {
  render() {
    return (
      <div className="panel panel-default">
        <div className="panel-heading" role="tab" id="headingThree">
          <h4 className="panel-title">
            <a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseThree" aria-expanded="true" aria-controls="collapseThree">
              Response
            </a>
          </h4>
        </div>
        <div id="collapseThree" className="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingThree">
          <div className="panel-body">
            <pre>{this.props.response_body_as_string}</pre>
          </div>
        </div>
      </div>
    )
  }
}

Response.propTypes = {
  response_body_as_string: PropTypes.string.isRequired
}
