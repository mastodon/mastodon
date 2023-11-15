import { useCallback } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link, Switch, Route, useHistory } from 'react-router-dom';

import { useDispatch } from 'react-redux';


import { ReactComponent as AccountCircleIcon } from '@material-symbols/svg-600/outlined/account_circle.svg';
import { ReactComponent as ArrowRightAltIcon } from '@material-symbols/svg-600/outlined/arrow_right_alt.svg';
import { ReactComponent as ContentCopyIcon } from '@material-symbols/svg-600/outlined/content_copy.svg';
import { ReactComponent as EditNoteIcon } from '@material-symbols/svg-600/outlined/edit_note.svg';
import { ReactComponent as PersonAddIcon } from '@material-symbols/svg-600/outlined/person_add.svg';

import { focusCompose } from 'flavours/glitch/actions/compose';
import { Icon }  from 'flavours/glitch/components/icon';
import Column from 'flavours/glitch/features/ui/components/column';
import { me } from 'flavours/glitch/initial_state';
import { useAppSelector } from 'flavours/glitch/store';
import { assetHost } from 'flavours/glitch/utils/config';
import illustration from 'mastodon/../images/elephant_ui_conversation.svg';

import { Step } from './components/step';
import { Follows } from './follows';
import { Profile } from './profile';
import { Share } from './share';

const messages = defineMessages({
  template: { id: 'onboarding.compose.template', defaultMessage: 'Hello #Mastodon!' },
});

const Onboarding = () => {
  const account = useAppSelector(state => state.getIn(['accounts', me]));
  const dispatch = useDispatch();
  const intl = useIntl();
  const history = useHistory();

  const handleComposeClick = useCallback(() => {
    dispatch(focusCompose(history, intl.formatMessage(messages.template)));
  }, [dispatch, intl, history]);

  return (
    <Column>
      <Switch>
        <Route path='/start' exact>
          <div className='scrollable privacy-policy'>
            <div className='column-title'>
              <img src={illustration} alt='' className='onboarding__illustration' />
              <h3><FormattedMessage id='onboarding.start.title' defaultMessage="You've made it!" /></h3>
              <p><FormattedMessage id='onboarding.start.lead' defaultMessage="Your new Mastodon account is ready to go. Here's how you can make the most of it:" /></p>
            </div>

            <div className='onboarding__steps'>
              <Step to='/start/profile' completed={(!account.get('avatar').endsWith('missing.png')) || (account.get('display_name').length > 0 && account.get('note').length > 0)} icon='address-book-o' iconComponent={AccountCircleIcon} label={<FormattedMessage id='onboarding.steps.setup_profile.title' defaultMessage='Customize your profile' />} description={<FormattedMessage id='onboarding.steps.setup_profile.body' defaultMessage='Others are more likely to interact with you with a filled out profile.' />} />
              <Step to='/start/follows' completed={(account.get('following_count') * 1) >= 1} icon='user-plus' iconComponent={PersonAddIcon} label={<FormattedMessage id='onboarding.steps.follow_people.title' defaultMessage='Find at least {count, plural, one {one person} other {# people}} to follow' values={{ count: 7 }} />} description={<FormattedMessage id='onboarding.steps.follow_people.body' defaultMessage="You curate your own home feed. Let's fill it with interesting people." />} />
              <Step onClick={handleComposeClick} completed={(account.get('statuses_count') * 1) >= 1} icon='pencil-square-o' iconComponent={EditNoteIcon} label={<FormattedMessage id='onboarding.steps.publish_status.title' defaultMessage='Make your first post' />} description={<FormattedMessage id='onboarding.steps.publish_status.body' defaultMessage='Say hello to the world.' values={{ emoji: <img className='emojione' alt='🐘' src={`${assetHost}/emoji/1f418.svg`} /> }} />} />
              <Step to='/start/share' icon='copy' iconComponent={ContentCopyIcon} label={<FormattedMessage id='onboarding.steps.share_profile.title' defaultMessage='Share your profile' />} description={<FormattedMessage id='onboarding.steps.share_profile.body' defaultMessage='Let your friends know how to find you on Mastodon!' />} />
            </div>

            <p className='onboarding__lead'><FormattedMessage id='onboarding.start.skip' defaultMessage="Don't need help getting started?" /></p>

            <div className='onboarding__links'>
              <Link to='/explore' className='onboarding__link'>
                <FormattedMessage id='onboarding.actions.go_to_explore' defaultMessage='Take me to trending' />
                <Icon icon={ArrowRightAltIcon} />
              </Link>

              <Link to='/home' className='onboarding__link'>
                <FormattedMessage id='onboarding.actions.go_to_home' defaultMessage='Take me to my home feed' />
                <Icon icon={ArrowRightAltIcon} />
              </Link>
            </div>
          </div>
        </Route>

        <Route path='/start/profile' component={Profile} />
        <Route path='/start/follows' component={Follows} />
        <Route path='/start/share' component={Share} />
      </Switch>

      <Helmet>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

export default Onboarding;
