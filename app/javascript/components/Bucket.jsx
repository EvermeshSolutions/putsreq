import React from 'react'
import { connect } from 'react-redux'
import Request from './request'
import ReactPaginate from 'react-paginate'
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

  handlePageChange(data) {
    const page = data.selected + 1
    this.props.handlePageChange(this.props.bucket, page)
  }

  renderPagination() {
    return (
      <ReactPaginate previousLabel={"Previous"}
        nextLabel={"Next"}
        breakLabel={<span>...</span>}
        pageCount={this.props.bucket.requests_count}
        marginPagesDisplayed={2}
        pageRangeDisplayed={5}
        containerClassName={"pagination"}
        onPageChange={this.handlePageChange.bind(this)}
        subContainerClassName={"pages pagination"}
        activeClassName={"active"} />
    )
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
        <hr />
        {this.renderPagination()}
        <hr />
        <Request {...this.props.bucket.last_request} />
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
