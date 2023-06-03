import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { fetchSuggestions } from 'mastodon/actions/suggestions';
import { markAsPartial } from 'mastodon/actions/timelines';
import Column from 'mastodon/components/column';
import ColumnBackButton from 'mastodon/components/column_back_button';
import { EmptyAccount } from 'mastodon/components/empty_account';
import Account from 'mastodon/containers/account_container';
import { me } from 'mastodon/initial_state';
import { makeGetAccount } from 'mastodon/selectors';

import ProgressIndicator from './components/progress_indicator';

const mapStateToProps = () => {
  const getAccount = makeGetAccount();

  return state => ({
    account: getAccount(state, me),
    suggestions: state.getIn(['suggestions', 'items']),
    isLoading: state.getIn(['suggestions', 'isLoading']),
  });
};

class Follows extends PureComponent {

  static propTypes = {
    onBack: PropTypes.func,
    dispatch: PropTypes.func.isRequired,
    suggestions: ImmutablePropTypes.list,
    account: ImmutablePropTypes.map,
    isLoading: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchSuggestions(true));
  }

  componentWillUnmount () {
    const { dispatch } = this.props;
    dispatch(markAsPartial('home'));
  }

  render () {
    const { onBack, isLoading, suggestions, account, multiColumn } = this.props;

    let loadedContent;

    if (isLoading) {
      loadedContent = (new Array(8)).fill().map((_, i) => <EmptyAccount key={i} />);
    } else if (suggestions.isEmpty()) {
      loadedContent = <div className='follow-recommendations__empty'><FormattedMessage id='onboarding.follows.empty' defaultMessage='Unfortunately, no results can be shown right now. You can try using search or browsing the explore page to find people to follow, or try again later.' /></div>;
    } else {
      loadedContent = suggestions.map(suggestion => <Account id={suggestion.get('account')} key={suggestion.get('account')} />);
    }

    return (
      <Column>
        <ColumnBackButton multiColumn={multiColumn} onClick={onBack} />

        <div className='scrollable privacy-policy'>
          <div className='column-title'>
            <h3><FormattedMessage id='onboarding.follows.title' defaultMessage='Popular on Mastodon' /></h3>
            <p><FormattedMessage id='onboarding.follows.lead' defaultMessage='You curate your own home feed. The more people you follow, the more active and interesting it will be. These profiles may be a good starting point—you can always unfollow them later!' /></p>
          </div>

          <ProgressIndicator steps={7} completed={account.get('following_count') * 1} />

          <div className='follow-recommendations'>
            {loadedContent}
          </div>

          <p className='onboarding__lead'><FormattedMessage id='onboarding.tips.accounts_from_other_servers' defaultMessage='<strong>Did you know?</strong> Since Mastodon is decentralized, some profiles you come across will be hosted on servers other than yours. And yet you can interact with them seamlessly! Their server is in the second half of their username!' values={{ strong: chunks => <strong>{chunks}</strong> }} /></p>

          <div className='onboarding__footer'>
            <button className='link-button' onClick={onBack}><FormattedMessage id='onboarding.actions.back' defaultMessage='Take me back' /></button>
          </div>
        </div>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(Follows);
