import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { useDispatch } from 'react-redux';


import { fetchSuggestions } from 'flavours/glitch/actions/suggestions';
import { markAsPartial } from 'flavours/glitch/actions/timelines';
import { ColumnBackButton } from 'flavours/glitch/components/column_back_button';
import { EmptyAccount } from 'flavours/glitch/components/empty_account';
import Account from 'flavours/glitch/containers/account_container';
import { useAppSelector } from 'flavours/glitch/store';

export const Follows = () => {
  const dispatch = useDispatch();
  const isLoading = useAppSelector(state => state.getIn(['suggestions', 'isLoading']));
  const suggestions = useAppSelector(state => state.getIn(['suggestions', 'items']));

  useEffect(() => {
    dispatch(fetchSuggestions(true));

    return () => {
      dispatch(markAsPartial('home'));
    };
  }, [dispatch]);

  let loadedContent;

  if (isLoading) {
    loadedContent = (new Array(8)).fill().map((_, i) => <EmptyAccount key={i} />);
  } else if (suggestions.isEmpty()) {
    loadedContent = <div className='follow-recommendations__empty'><FormattedMessage id='onboarding.follows.empty' defaultMessage='Unfortunately, no results can be shown right now. You can try using search or browsing the explore page to find people to follow, or try again later.' /></div>;
  } else {
    loadedContent = suggestions.map(suggestion => <Account id={suggestion.get('account')} key={suggestion.get('account')} withBio />);
  }

  return (
    <>
      <ColumnBackButton />

      <div className='scrollable privacy-policy'>
        <div className='column-title'>
          <h3><FormattedMessage id='onboarding.follows.title' defaultMessage='Popular on Mastodon' /></h3>
          <p><FormattedMessage id='onboarding.follows.lead' defaultMessage='You curate your own home feed. The more people you follow, the more active and interesting it will be. These profiles may be a good starting point—you can always unfollow them later!' /></p>
        </div>

        <div className='follow-recommendations'>
          {loadedContent}
        </div>

        <p className='onboarding__lead'><FormattedMessage id='onboarding.tips.accounts_from_other_servers' defaultMessage='<strong>Did you know?</strong> Since Mastodon is decentralized, some profiles you come across will be hosted on servers other than yours. And yet you can interact with them seamlessly! Their server is in the second half of their username!' values={{ strong: chunks => <strong>{chunks}</strong> }} /></p>

        <div className='onboarding__footer'>
          <Link className='link-button' to='/start'><FormattedMessage id='onboarding.actions.back' defaultMessage='Take me back' /></Link>
        </div>
      </div>
    </>
  );
};
