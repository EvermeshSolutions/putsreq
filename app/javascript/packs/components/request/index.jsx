import React from 'react'
import { connect } from 'react-redux'
import Header from './Header'

export default class Request extends React.Component {
  render() {
    return (
      <Header headers={this.props.headers} time_ago_in_words={this.props.time_ago_in_words} created_at={this.props.created_at} />
    )
  }
}
