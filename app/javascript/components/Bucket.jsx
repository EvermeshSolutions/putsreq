import React from 'react'
import { connect } from 'react-redux'
import Request from './request'
import Pagination from './Pagination'
import { fetchFromPage, handlePageChange } from '../actions'

class Bucket extends React.Component {
  componentWillMount() {
    this.props.fetchFromPage()
  }

  renderFirstRequestLink() {
    if(!this.props.bucket.request) { return }

    return (
      <em>Request ID: <a href={this.props.bucket.request.path} target="_blank">{this.props.bucket.request.id}</a></em>
    )
  }

  renderFirstRequest() {
    if(!this.props.bucket.first_request) { return }

    return (
      <p>
        <em>First request at: {this.props.bucket.first_request.created_at}</em> <br />
        <em>Last request at: {this.props.bucket.last_request.created_at}</em> <br />

        {this.renderFirstRequestLink()}
      </p>
    )
  }

  handlePageChange(page) {
    this.props.handlePageChange(page)
  }

  renderPagination() {
    if(!this.props.bucket.request) { return }

    return (
      <Pagination
          pageCount={this.props.bucket.requests_count}
          page={this.props.bucket.page}
          onPageChange={this.handlePageChange.bind(this)}
      />
    )
  }

  renderRequestOrLoading() {
    if(this.props.bucket.loading) {
      return (
        <div><em><strong>Loading...</strong></em></div>
      )
    }

    return (<Request {...this.props.bucket.request} />)
  }

  render() {
    if(!this.props.bucket) { return }

    return (
      <div>
        <div className="row">
          <div className="col-md-6">
            {this.renderFirstRequest()}
          </div>
          <div className="col-md-6"></div>
        </div>
        {this.renderPagination()}
        {this.renderRequestOrLoading()}
      </div>
    )
  }
}

const mapStateToProps = (state) => ({
  bucket: state.bucket
})

const mapDispatchToProps = {
  handlePageChange: handlePageChange,
  fetchFromPage: fetchFromPage
}

export default connect(mapStateToProps, mapDispatchToProps)(Bucket)
