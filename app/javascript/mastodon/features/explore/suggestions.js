import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Account from 'mastodon/containers/account_container';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import { connect } from 'react-redux';
import { fetchSuggestions } from 'mastodon/actions/suggestions';

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

    return (
      <div className='explore__links'>
        {isLoading ? (<LoadingIndicator />) : suggestions.map(suggestion => (
          <Account key={suggestion.get('account')} id={suggestion.get('account')} />
        ))}
      </div>
    );
  }

}
