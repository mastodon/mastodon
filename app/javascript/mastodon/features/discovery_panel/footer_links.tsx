import { FormattedMessage } from 'react-intl';

import { NavLink } from 'react-router-dom';

import {
  statusPageUrl,
  termsOfServiceEnabled,
  profile_directory as canViewProfileDirectory,
  version,
  source_url,
  title,
  domain,
} from '@/mastodon/initial_state';

import classes from './footer_links.module.scss';

export const FooterLinks: React.FC<{
  context: 'navigation' | 'search';
  multiColumn?: boolean;
}> = ({ context, multiColumn }) => {
  const multiColumnLinkAttrs = multiColumn
    ? {
        target: '_blank',
      }
    : undefined;

  return (
    <div className={classes.root} data-context={context}>
      <section>
        <h2 className={classes.heading}>{title ?? domain}</h2>
        <ul className={classes.list}>
          <li>
            <NavLink to='/about' {...multiColumnLinkAttrs}>
              <FormattedMessage
                id='footer.about_this_server'
                defaultMessage='About'
              />
            </NavLink>
          </li>
          {termsOfServiceEnabled && (
            <li>
              <NavLink
                to='/terms-of-service'
                rel='terms-of-service'
                {...multiColumnLinkAttrs}
              >
                <FormattedMessage
                  id='footer.terms_of_service_short'
                  defaultMessage='Terms'
                />
              </NavLink>
            </li>
          )}
          <li>
            <NavLink
              to='/privacy-policy'
              rel='privacy-policy'
              {...multiColumnLinkAttrs}
            >
              <FormattedMessage
                id='footer.privacy_policy_short'
                defaultMessage='Privacy'
              />
            </NavLink>
          </li>
          {statusPageUrl && (
            <li>
              <a href={statusPageUrl} target='_blank' rel='noopener'>
                <FormattedMessage id='footer.status' defaultMessage='Status' />
              </a>
            </li>
          )}
          {canViewProfileDirectory && (
            <li>
              <NavLink to='/directory'>
                <FormattedMessage
                  id='footer.directory_short'
                  defaultMessage='Directory'
                />
              </NavLink>
            </li>
          )}
        </ul>
      </section>

      <section>
        <h2 className={classes.heading}>{`Mastodon v${version}`}</h2>
        <ul className={classes.list}>
          <li>
            <a href={source_url} rel='noopener' target='_blank'>
              <FormattedMessage
                id='footer.source_code'
                defaultMessage='Source Code'
              />
            </a>
          </li>
          <li>
            <a
              href='https://joinmastodon.org/apps'
              target='_blank'
              rel='noopener'
            >
              <FormattedMessage id='footer.apps' defaultMessage='Apps' />
            </a>
          </li>
          <li>
            <a
              href='https://help.joinmastodon.org/'
              target='_blank'
              rel='noopener'
            >
              <FormattedMessage id='footer.help' defaultMessage='Help' />
            </a>
          </li>
          <li>
            <a
              href='https://community.joinmastodon.org/'
              target='_blank'
              rel='noopener'
            >
              <FormattedMessage
                id='footer.feedback'
                defaultMessage='Feedback'
              />
            </a>
          </li>
        </ul>
      </section>
    </div>
  );
};
