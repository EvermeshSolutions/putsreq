import React, { Component } from 'react'
import { connect } from 'react-redux'
import PropTypes from 'prop-types'

export default class Header extends Component {
  render() {
    return (
      <div className="panel panel-default">
        <span className="pull-right label label-info" title={this.props.created_at}>{this.props.time_ago_in_words}</span>
        <div className="panel-heading" role="tab" id="headingOne">
          <h4 className="panel-title">
            <a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
              Headers
            </a>
          </h4>
        </div>
        <div id="collapseOne" className="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingOne">
          <div className="panel-body">
            <pre>{this.props.headers_as_string}</pre>
          </div>
        </div>
      </div>
    )
  }
}

Header.propTypes = {
  created_at: PropTypes.string.isRequired,
  time_ago_in_words: PropTypes.string.isRequired,
  headers_as_string: PropTypes.string.isRequired
}
