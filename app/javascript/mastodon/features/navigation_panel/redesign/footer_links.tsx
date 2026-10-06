import { FormattedMessage } from 'react-intl';

import { NavLink } from 'react-router-dom';

import {
  statusPageUrl,
  termsOfServiceEnabled,
  profile_directory as canViewProfileDirectory,
  version,
  source_url,
} from '@/mastodon/initial_state';

import classes from './footer_links.module.scss';

export const NavigationFooterLinks: React.FC<{
  multiColumn?: boolean;
  withVersionInfo?: boolean;
}> = ({ multiColumn, withVersionInfo }) => {
  const multiColumnLinkAttrs = multiColumn
    ? {
        target: '_blank',
      }
    : undefined;

  return (
    <div className={classes.root}>
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
      {withVersionInfo && (
        <p>
          {`Mastodon v${version} `}&nbsp;
          <a href={source_url} rel='noopener' target='_blank'>
            <FormattedMessage
              id='footer.source_code'
              defaultMessage='View source code'
            />
          </a>
        </p>
      )}
    </div>
  );
};
