import React from 'react';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { refreshTimeline } from '../../../actions/timelines';

const messages = defineMessages({
  placeholder: { id: 'search.placeholder', defaultMessage: 'Search' }
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'search', 'unread']) > 0,
  accessToken: state.getIn(['meta', 'access_token'])
});

class SearchStatus extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);

    const { dispatch } = this.props;
    dispatch(refreshTimeline('search', ''));
  }

  handleKeyDown (e) {
    if (e.keyCode === 13) {
      this.handleSubmit(e);
    }
  }

  handleSubmit (e) {
    const { dispatch } = this.props;

    const query = e.target.value;

    dispatch(refreshTimeline('search', query));
  }

  render () {
    const { intl, value } = this.props;

    return (
      <div className='search-timeline'>
        <input
          className='search__input'
          type='text'
          placeholder={intl.formatMessage(messages.placeholder)}
          onKeyDown={this.handleKeyDown}
        />

        <div role='button' tabIndex='0' className='search__icon'>
          <i className={`fa fa-search active`} />
        </div>
      </div>
    );
  }
}

export default connect(mapStateToProps)(injectIntl(SearchStatus));
