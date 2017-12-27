import React from 'react'
import Request from './request'
import { connect } from 'react-redux'
import { Maybe } from 'ramda-fantasy'
import * as R from 'ramda'

export default class Requests extends React.Component {
  renderRequests() {
    return Maybe(R.path(['bucket', 'requests'], this.props)).getOrElse([]).map(function(request, i){
      return (
        <Request request={request} key={i} />
      )
    })
  }
  render() {
    return (
      <div className="panel-group request-show" id="accordion" role="tablist" aria-multiselectable="true">
        {this.renderRequests()}
      </div>
    )
  }
}
