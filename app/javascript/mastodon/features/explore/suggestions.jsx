import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { fetchSuggestions } from 'mastodon/actions/suggestions';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { WithRouterPropTypes } from 'mastodon/utils/react_router';

import { Card } from './components/card';

const mapStateToProps = state => ({
  suggestions: state.getIn(['suggestions', 'items']),
  isLoading: state.getIn(['suggestions', 'isLoading']),
});

class Suggestions extends PureComponent {

  static propTypes = {
    isLoading: PropTypes.bool,
    suggestions: ImmutablePropTypes.list,
    dispatch: PropTypes.func.isRequired,
    ...WithRouterPropTypes,
  };

  componentDidMount () {
    const { dispatch, suggestions, history } = this.props;

    // If we're navigating back to the screen, do not trigger a reload
    if (history.action === 'POP' && suggestions.size > 0) {
      return;
    }

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
      <div className='explore__suggestions scrollable' data-nosnippet>
        {isLoading ? <LoadingIndicator /> : suggestions.map(suggestion => (
          <Card
            key={suggestion.get('account')}
            id={suggestion.get('account')}
            source={suggestion.getIn(['sources', 0])}
          />
        ))}
      </div>
    );
  }

}

export default connect(mapStateToProps)(withRouter(Suggestions));
