import React, { Component } from 'react'
import PropTypes from 'prop-types'

export default class Pagination extends Component {
  handleFirstPage() {
    this.props.onPageChange(1)
  }

  handlePreviousPage() {
    const previousPage = this.props.page - 1
    if(previousPage > 0) { this.props.onPageChange(previousPage) }
  }

  handleNextPage() {
    const nextPage = this.props.page + 1
    if(nextPage <= this.props.pageCount) { this.props.onPageChange(nextPage) }
  }

  handleLastPage() {
    this.props.onPageChange(this.props.pageCount)
  }

  firstClassNames() {
    if(this.props.page <= 1) { return 'disabled' }
  }

  previousClassNames() {
    const previousPage = this.props.page - 1

    if(previousPage <= 0) { return 'disabled' }
  }

  nextClassNames() {
    const nextPage = this.props.page + 1

    if(nextPage > this.props.pageCount) { return 'disabled' }
  }

  lastClassNames() {
    if(this.props.page >= this.props.pageCount) { return 'disabled' }
  }

  render() {
    return(
      <ul className="pagination">
        <li className={this.firstClassNames()}>
          <a onClick={this.handleFirstPage.bind(this)}>First</a>
        </li>
        <li className={this.previousClassNames()}>
          <a onClick={this.handlePreviousPage.bind(this)}>Previous</a>
        </li>
        <li className={this.nextClassNames()}>
          <a onClick={this.handleNextPage.bind(this)}>Next</a>
        </li>
        <li className={this.lastClassNames()}>
          <a onClick={this.handleLastPage.bind(this)}>Last</a>
        </li>
      </ul>
    )
  }
}

Pagination.propTypes = {
  page: PropTypes.number.isRequired,
  pageCount: PropTypes.number.isRequired,
  onPageChange: PropTypes.func.isRequired
}
