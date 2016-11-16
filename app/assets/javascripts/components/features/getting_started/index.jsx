import Column from '../ui/components/column';
import { Link } from 'react-router';
import { FormattedMessage } from 'react-intl';

const GettingStarted = () => {
  return (
    <Column>
      <div className='static-content'>
        <h1><FormattedMessage id='getting_started.heading' defaultMessage='Getting started' /></h1>
        <p><FormattedMessage id='getting_started.about_addressing' defaultMessage='You can follow people if you know their username and the domain they are on by entering an e-mail-esque address into the form at the top of the sidebar.' /></p>
        <p><FormattedMessage id='getting_started.about_shortcuts' defaultMessage='If the target user is on the same domain as you, just the username will work. The same rule applies to mentioning people in statuses.' /></p>
        <p><FormattedMessage id='getting_started.about_developer' defaultMessage='The developer of this project can be followed as Gargron@mastodon.social' /></p>
      </div>
    </Column>
  );
};

export default GettingStarted;
