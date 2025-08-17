import { FormattedMessage } from 'react-intl';

// import { a } from 'react-router-dom';

import {
  domain,
  version,
  source_url,
  statusPageUrl,
  profile_directory as canProfileDirectory,
  termsOfServiceEnabled,
} from 'mastodon/initial_state';

const DividingCircle: React.FC = () => <span aria-hidden>{' · '}</span>;

export const LinkFooter: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn }) => {
  return (
    <div className='a-footer'>
      <p>
        <strong>{domain}</strong>:{' '}
        <a href='/about' target={multiColumn ? '_blank' : undefined}>
          <FormattedMessage id='footer.about' defaultMessage='About' />
        </a>
        {statusPageUrl && (
          <>
            <DividingCircle />
            <a href={statusPageUrl} target='_blank' rel='noopener'>
              <FormattedMessage id='footer.status' defaultMessage='Status' />
            </a>
          </>
        )}
        {canProfileDirectory && (
          <>
            <DividingCircle />
            <a href='/directory'>
              <FormattedMessage
                id='footer.directory'
                defaultMessage='Profiles directory'
              />
            </a>
          </>
        )}
        <DividingCircle />
        <a
          href='/privacy-policy'
          target={multiColumn ? '_blank' : undefined}
          rel='privacy-policy'
        >
          <FormattedMessage
            id='footer.privacy_policy'
            defaultMessage='Privacy policy'
          />
        </a>
        {termsOfServiceEnabled && (
          <>
            <DividingCircle />
            <a
              href='/terms-of-service'
              target={multiColumn ? '_blank' : undefined}
              rel='terms-of-service'
            >
              <FormattedMessage
                id='footer.terms_of_service'
                defaultMessage='Terms of service'
              />
            </a>
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
        <a href='/keyboard-shortcuts'>
          <FormattedMessage
            id='footer.keyboard_shortcuts'
            defaultMessage='Keyboard shortcuts'
          />
        </a>
        <DividingCircle />
        <a href={source_url} rel='noopener' target='_blank'>
          <FormattedMessage
            id='footer.source_code'
            defaultMessage='View source code'
          />
        </a>
        <DividingCircle />
        <span className='version'>v{version}</span>
      </p>
    </div>
  );
};
