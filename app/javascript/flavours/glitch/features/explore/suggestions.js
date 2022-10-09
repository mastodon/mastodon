import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import AccountCard from 'flavours/glitch/features/directory/components/account_card';
import LoadingIndicator from 'flavours/glitch/components/loading_indicator';
import { connect } from 'react-redux';
import { fetchSuggestions, dismissSuggestion } from 'flavours/glitch/actions/suggestions';

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

  handleDismiss = (accountId) => {
    const { dispatch } = this.props;
    dispatch(dismissSuggestion(accountId));
  }

  render () {
    const { isLoading, suggestions } = this.props;

    return (
      <div className='explore__suggestions'>
        {isLoading ? <LoadingIndicator /> : suggestions.map(suggestion => (
          <AccountCard key={suggestion.get('account')} id={suggestion.get('account')} onDismiss={suggestion.get('source') === 'past_interactions' ? this.handleDismiss : null} />
        ))}
      </div>
    );
  }

}
