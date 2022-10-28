import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import AccountCard from 'mastodon/features/directory/components/account_card';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import { connect } from 'react-redux';
import { fetchSuggestions } from 'mastodon/actions/suggestions';
import { FormattedMessage } from 'react-intl';

const mapStateToProps = state => ({
  suggestions: state.getIn(['suggestions', 'items']),
  isLoading: state.getIn(['suggestions', 'isLoading']),
});

export default @connect(mapStateToProps)
class Suggestions extends React.PureComponent {

  static propTypes = {
    isLoading: PropTypes.bool,
    suggestions: ImmutablePropTypes.list,
    dispatch: PropTypes.func.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchSuggestions(true));
  }

  render () {
    const { isLoading, suggestions } = this.props;

    if (!isLoading && suggestions.isEmpty()) {
      return (
        <div className='explore__suggestions scrollable scrollable--flex'>
          <div className='empty-column-indicator'>
            <FormattedMessage id='empty_column.explore_statuses' defaultMessage='Nothing is trending right now. Check back later!' />
          </div>
        </div>
      );
    }

    return (
      <div className='explore__suggestions'>
        {isLoading ? <LoadingIndicator /> : suggestions.map(suggestion => (
          <AccountCard key={suggestion.get('account')} id={suggestion.get('account')} />
        ))}
      </div>
    );
  }

}
