import React from 'react'
import { connect } from 'react-redux'
import Request from './request'
import ReactPaginate from 'react-paginate'
import { fetchBucket } from '../actions/bucket'

class Bucket extends React.Component {
  componentWillMount() {
    fetchBucket()
  }

  renderFirstRequestLink() {
    if(!this.props.bucket.first_request) { return }

    return (
      <em>Request ID: <a href={this.props.bucket.last_request_path} target="_blank">{this.props.bucket.last_request.id}</a></em>
    )
  }

  renderFirstRequest() {
    if(!this.props.bucket.first_request) { return }

    return (
      <p>
        <em>
          First request at: {this.props.bucket.first_request.created_at} <br />
          Last request at: {this.props.bucket.last_request.created_at} <br />

          {this.renderFirstRequestLink()}
        </em>
      </p>
    )
  }

  handlePageClick(data) {
    let selected = data.selected
    let offset = Math.ceil(selected * this.props.perPage)

    this.setState({offset: offset}, () => {
      console.log(this)
      $.ajax({
        url      : this.props.bucket.path,
        data     : {limit: this.props.perPage, offset: this.state.offset},
        dataType : 'json',
        type     : 'GET',

        success: data => {
          // this.setState({data: data.comments, pageCount: Math.ceil(data.meta.total_count / data.meta.limit)});
          console.log(data)
        },

        error: (xhr, status, err) => {
          console.error(this.props.bucket.path, status, err.toString());
        }
      })
    })
  }

  renderPagination() {
    return (
      <ReactPaginate previousLabel={"previous"}
        nextLabel={"next"}
        breakLabel={<a href="">...</a>}
        breakClassName={"break-me"}
        pageCount={this.props.bucket.requests_count}
        marginPagesDisplayed={2}
        pageRangeDisplayed={5}
        containerClassName={"pagination"}
        onPageChange={this.handlePageClick.bind(this)}
        subContainerClassName={"pages pagination"}
        activeClassName={"active"} />
    )
  }

  render() {
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


const mapDispatchToProps = {}

export default connect(mapStateToProps, mapDispatchToProps)(Bucket)
