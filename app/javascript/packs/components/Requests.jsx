import React from 'react'
import Request from './request'
import { connect } from 'react-redux'
import { Maybe } from 'ramda-fantasy'
import * as R from 'ramda'

export default class Requests extends React.Component {
  render() {
    return (
      <div className="panel-group request-show" id="accordion" role="tablist" aria-multiselectable="true">
        <Request {...this.props.last_request} />
      </div>
    )
  }
}
