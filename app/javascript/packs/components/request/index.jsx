import React from 'react'
import { connect } from 'react-redux'
import Header from './Header'

export default class Request extends React.Component {
  render() {
    return (
      <div>
        <Header headers_as_string={this.props.headers_as_string} time_ago_in_words={this.props.time_ago_in_words} created_at={this.props.created_at} />
        <div class="panel panel-default">
          <div class="panel-heading" role="tab" id="headingTwo">
            <h4 class="panel-title">
              <a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo" aria-expanded="true" aria-controls="collapseTwo">
                {this.props.request_method} {this.props.path}
              </a>
            </h4>
          </div>
          <div id="collapseTwo" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingTwo">
            <div class="panel-body">
              <pre>{this.props.body_as_string}</pre>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
