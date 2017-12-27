import React from 'react'
import { connect } from 'react-redux'
import Header from './Header'

export default class Request extends React.Component {
  render() {
    return (
      <Header headers={this.props.request.headers} time_ago_in_words={this.props.request.time_ago_in_words} created_at={this.props.request.created_at} />
    )
  }
}
