import PropTypes from 'prop-types';
import React, { Component, Fragment } from 'react';
import { FormattedMessage } from 'react-intl';
import { NavLink } from 'react-router-dom';

export default class SectionHeadline extends Component {

  static propTypes = {
    timelineId: PropTypes.string.isRequired,
    to: PropTypes.string.isRequired,
    pinned: PropTypes.bool.isRequired,
    onlyMedia: PropTypes.bool.isRequired,
    onClick: PropTypes.func,
  };

  shouldComponentUpdate (nextProps) {
    return (
      this.props.onlyMedia !== nextProps.onlyMedia ||
      this.props.pinned !== nextProps.pinned ||
      this.props.to !== nextProps.to ||
      this.props.timelineId !== nextProps.timelineId
    );
  }

  handleClick = e => {
    const { onClick } = this.props;

    if (typeof onClick === 'function') {
      e.preventDefault();

      onClick.call(this, e);
    }
  }

  render () {
    const { timelineId, to, pinned, onlyMedia } = this.props;

    return (
      <div className={`${timelineId}-timeline__section-headline`}>
        {pinned ? (
          <Fragment>
            <a href={to} className={!onlyMedia ? 'active' : undefined} onClick={this.handleClick}>
              <FormattedMessage id='timeline.posts' defaultMessage='Toots' />
            </a>
            <a href={`${to}/media`} className={onlyMedia ? 'active' : undefined} onClick={this.handleClick}>
              <FormattedMessage id='timeline.media' defaultMessage='Media' />
            </a>
          </Fragment>
        ) : (
          <Fragment>
            <NavLink exact to={to} replace><FormattedMessage id='timeline.posts' defaultMessage='Toots' /></NavLink>
            <NavLink exact to={`${to}/media`} replace><FormattedMessage id='timeline.media' defaultMessage='Media' /></NavLink>
          </Fragment>
        )}
      </div>
    );
  }

}
