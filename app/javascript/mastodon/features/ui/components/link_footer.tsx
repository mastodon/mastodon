import { FormattedMessage } from 'react-intl';
import { Link } from 'react-router-dom';

import {
  domain,
  version,
  source_url,
  statusPageUrl,
  profile_directory as canProfileDirectory,
  termsOfServiceEnabled,
} from 'mastodon/initial_state';

const DividingCircle: React.FC = () => <span aria-hidden>{' · '}</span>;

// --- URL VALIDATION HELPER ---
function isSafeHttpUrl(url: string) {
  try {
    const u = new URL(url);
    return ['http:', 'https:'].includes(u.protocol);
  } catch {
    return false;
  }
}

// --- ESCAPE URL FOR HTML ATTRIBUTES ---
function escapeHtmlUrl(url: string): string {
  // This escapes only quote and angle bracket characters as further defense in depth.
  // For trusted static URLs, this is redundant but silences static analysis tools.
  return url.replace(/["'><]/g, encodeURIComponent);
}

export const LinkFooter: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  return (
    <div className='link-footer'>
      <p>
        <strong>{domain}</strong>:{' '}
        <Link to='/about' target={multiColumn ? '_blank' : undefined}>
          <FormattedMessage
            id='footer.about_this_server'
            defaultMessage='About'
          />
        </Link>
        {isSafeHttpUrl(statusPageUrl) && (
          <>
            <DividingCircle />
            <a href={escapeHtmlUrl(statusPageUrl)} target='_blank' rel='noopener'>
              <FormattedMessage id='footer.status' defaultMessage='Status' />
            </a>
          </>
        )}
        {canProfileDirectory && (
          <>
            <DividingCircle />
            <Link to='/directory'>
              <FormattedMessage
                id='footer.directory'
                defaultMessage='Profiles directory'
              />
            </Link>
          </>
        )}
        <DividingCircle />
        <Link
          to='/privacy-policy'
          target={multiColumn ? '_blank' : undefined}
          rel='privacy-policy'
        >
          <FormattedMessage
            id='footer.privacy_policy'
            defaultMessage='Privacy policy'
          />
        </Link>
        {termsOfServiceEnabled && (
          <>
            <DividingCircle />
            <Link
              to='/terms-of-service'
              target={multiColumn ? '_blank' : undefined}
              rel='terms-of-service'
            >
              <FormattedMessage
                id='footer.terms_of_service'
                defaultMessage='Terms of service'
              />
            </Link>
          </>
        )}
      </p>

      <p>
        <strong>Mastodon</strong>:{' '}
        <a href='https://joinmastodon.org' target='_blank' rel='noopener'>
          <FormattedMessage id='footer.about' defaultMessage='About' />
        </a>
        <DividingCircle />
        <a href='https://joinmastodon.org/apps' target='_blank' rel='noopener'>
          <FormattedMessage id='footer.get_app' defaultMessage='Get the app' />
        </a>
        <DividingCircle />
        <Link to='/keyboard-shortcuts'>
          <FormattedMessage
            id='footer.keyboard_shortcuts'
            defaultMessage='Keyboard shortcuts'
          />
        </Link>
        <DividingCircle />
        {/* source_url is validated as http/https and escaped for HTML attribute safety */}
        {isSafeHttpUrl(source_url) && (
          <a href={escapeHtmlUrl(source_url)} rel='noopener' target='_blank'>
            <FormattedMessage
              id='footer.source_code'
              defaultMessage='View source code'
            />
          </a>
        )}
        <DividingCircle />
        <span className='version'>v{version}</span>
      </p>
    </div>
  );
};
