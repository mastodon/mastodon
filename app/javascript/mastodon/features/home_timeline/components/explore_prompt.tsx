import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import background from 'mastodon/../images/friends-cropped.png';
import { DismissableBanner } from 'mastodon/components/dismissable_banner';

export const ExplorePrompt = () => (
  <DismissableBanner id='home.explore_prompt'>
    <img
      src={background}
      alt=''
      className='dismissable-banner__background-image'
    />

    <h1>
      <FormattedMessage
        id='home.explore_prompt.title'
        defaultMessage='This is your home base within Mastodon.'
      />
    </h1>
    <p>
      <FormattedMessage
        id='home.explore_prompt.body'
        defaultMessage="Your home feed will have a mix of posts from the hashtags you've chosen to follow, the people you've chosen to follow, and the posts they boost. It's looking pretty quiet right now, so how about:"
      />
    </p>

    <div className='dismissable-banner__message__wrapper'>
      <div className='dismissable-banner__message__actions'>
        <Link to='/explore' className='button'>
          <FormattedMessage
            id='home.actions.go_to_explore'
            defaultMessage="See what's trending"
          />
        </Link>
        <Link to='/explore/suggestions' className='button button-tertiary'>
          <FormattedMessage
            id='home.actions.go_to_suggestions'
            defaultMessage='Find people to follow'
          />
        </Link>
      </div>
    </div>
  </DismissableBanner>
);
