import React from 'react'
import { connect } from 'react-redux'

export default class Request extends React.Component {
  render() {
    return (
      <div className="panel panel-default">
        <span className="pull-right label label-info"  title="2017-12-27 03:25:34 UTC">2 minutes ago</span>
        <div className="panel-heading" role="tab" id="headingOne">
          <h4 className="panel-title">
            <a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
              Headers
            </a>
          </h4>
        </div>
        <div id="collapseOne" className="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingOne">
          <div className="panel-body">
            <pre>{this.props.request.id}</pre>
          </div>
        </div>
      </div>
    )
  }
}
