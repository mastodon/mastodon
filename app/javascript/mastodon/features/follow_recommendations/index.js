import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { fetchSuggestions } from 'mastodon/actions/suggestions';
import { changeSetting, saveSettings } from 'mastodon/actions/settings';
import { requestBrowserPermission } from 'mastodon/actions/notifications';
import Column from 'mastodon/features/ui/components/column';
import Account from './components/account';
import Logo from 'mastodon/components/logo';
import imageGreeting from 'mastodon/../images/elephant_ui_greeting.svg';
import Button from 'mastodon/components/button';

const mapStateToProps = state => ({
  suggestions: state.getIn(['suggestions', 'items']),
  isLoading: state.getIn(['suggestions', 'isLoading']),
});

export default @connect(mapStateToProps)
class FollowRecommendations extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    suggestions: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
  };

  componentDidMount () {
    const { dispatch, suggestions } = this.props;

    // Don't re-fetch if we're e.g. navigating backwards to this page,
    // since we don't want followed accounts to disappear from the list

    if (suggestions.size === 0) {
      dispatch(fetchSuggestions(true));
    }
  }

  handleDone = () => {
    const { dispatch } = this.props;
    const { router } = this.context;

    dispatch(requestBrowserPermission((permission) => {
      if (permission === 'granted') {
        dispatch(changeSetting(['notifications', 'alerts', 'follow'], true));
        dispatch(changeSetting(['notifications', 'alerts', 'favourite'], true));
        dispatch(changeSetting(['notifications', 'alerts', 'reblog'], true));
        dispatch(changeSetting(['notifications', 'alerts', 'mention'], true));
        dispatch(changeSetting(['notifications', 'alerts', 'poll'], true));
        dispatch(changeSetting(['notifications', 'alerts', 'status'], true));
        dispatch(saveSettings());
      }
    }));

    router.history.push('/timelines/home');
  }

  render () {
    const { suggestions, isLoading } = this.props;

    return (
      <Column>
        <div className='scrollable'>
          <div className='column-title'>
            <Logo />
            <h3><FormattedMessage id='follow_recommendations.heading' defaultMessage="Follow people you'd like to see posts from! Here are some suggestions." /></h3>
            <p><FormattedMessage id='follow_recommendations.lead' defaultMessage="Posts from people you follow will show up in chronological order on your home feed. Don't be afraid to make mistakes, you can unfollow people just as easily any time!" /></p>
          </div>

          {!isLoading && (
            <React.Fragment>
              <div>
                {suggestions.map(suggestion => (
                  <Account key={suggestion.get('account')} id={suggestion.get('account')} />
                ))}
              </div>

              <div className='column-actions'>
                <img src={imageGreeting} alt='' className='column-actions__background' />
                <Button onClick={this.handleDone}><FormattedMessage id='follow_recommendations.done' defaultMessage='Done' /></Button>
              </div>
            </React.Fragment>
          )}
        </div>
      </Column>
    );
  }

}
