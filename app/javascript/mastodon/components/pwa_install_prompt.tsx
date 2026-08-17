import { useCallback, useEffect, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { bannerSettings } from 'mastodon/settings';

import { IconButton } from './icon_button';

interface InstallPromptChoice {
  outcome: 'accepted' | 'dismissed';
}

interface DeferredBeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<InstallPromptChoice>;
}

const isIos = () => {
  const { userAgent, maxTouchPoints } = window.navigator;

  return (
    /iPad|iPhone|iPod/i.test(userAgent) ||
    (/Macintosh/i.test(userAgent) && maxTouchPoints > 1)
  );
};

const isAndroid = () => /Android/i.test(window.navigator.userAgent);

const isStandalone = () =>
  (typeof window.matchMedia === 'function' &&
    window.matchMedia('(display-mode: standalone)').matches) ||
  (window.navigator as Navigator & { standalone?: boolean }).standalone ===
    true;

const INSTALL_BANNER_ID = 'pwa_install_prompt.install';
const IOS_BANNER_ID = 'pwa_install_prompt.ios';
const INSTALL_BANNER_DISMISS_MS = 30 * 24 * 60 * 60 * 1000;

const messages = defineMessages({
  dismiss: { id: 'dismissable_banner.dismiss', defaultMessage: 'Dismiss' },
  iosTitle: {
    id: 'about.highlander.install.iphone.title',
    defaultMessage: 'iPhone (Safari only)',
  },
  iosWarning: {
    id: 'about.highlander.install.iphone.warning',
    defaultMessage:
      "You must use <strong>Safari.</strong> The install option isn't available in Chrome or Firefox on iPhone.",
  },
  iosStep1: {
    id: 'about.highlander.install.iphone.step_1',
    defaultMessage:
      'Tap the <strong>Share</strong> button (the square with an upward arrow) at the bottom of the screen.',
  },
  iosStep2: {
    id: 'about.highlander.install.iphone.step_2',
    defaultMessage: 'Scroll down and tap <strong>Add to Home Screen</strong>.',
  },
  iosStep3: {
    id: 'about.highlander.install.iphone.step_3',
    defaultMessage:
      'Change the name if you like, then tap <strong>Add</strong>.',
  },
});

const richTextValues = {
  strong: (chunks: React.ReactNode) => <strong>{chunks}</strong>,
};

const iosSteps = [messages.iosStep1, messages.iosStep2, messages.iosStep3];

const getBannerDismissedAt = (id: string) => {
  const dismissedAt: unknown = bannerSettings.get(`${id}.dismissed_at`);

  return typeof dismissedAt === 'number' ? dismissedAt : null;
};

const isBannerSnoozed = (id: string) => {
  const dismissedAt = getBannerDismissedAt(id);

  return (
    dismissedAt !== null && Date.now() - dismissedAt < INSTALL_BANNER_DISMISS_MS
  );
};

interface InstallBannerProps {
  action?: React.ReactNode;
  children: React.ReactNode;
  onDismiss: () => void;
}

const InstallBanner: React.FC<InstallBannerProps> = ({
  action,
  children,
  onDismiss,
}) => {
  const intl = useIntl();

  return (
    <div className='pwa-install-prompt'>
      <div className='dismissable-banner'>
        <div className='dismissable-banner__action'>
          <IconButton
            icon='times'
            iconComponent={CloseIcon}
            title={intl.formatMessage(messages.dismiss)}
            onClick={onDismiss}
          />
        </div>

        <div className='dismissable-banner__message'>
          {children}

          {action && (
            <div className='dismissable-banner__message__actions__wrapper'>
              <div className='dismissable-banner__message__actions'>
                {action}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

const snoozeBanner = (id: string) => {
  bannerSettings.set(`${id}.dismissed_at`, Date.now());
};

export const PwaInstallPrompt: React.FC = () => {
  const [installPromptEvent, setInstallPromptEvent] =
    useState<DeferredBeforeInstallPromptEvent | null>(null);
  const [dismissedBanners, setDismissedBanners] = useState({
    install: isBannerSnoozed(INSTALL_BANNER_ID),
    ios: isBannerSnoozed(IOS_BANNER_ID),
  });

  const ios = isIos();
  const android = isAndroid();
  const standalone = isStandalone();

  useEffect(() => {
    if (!android || standalone) {
      return;
    }

    const handleBeforeInstallPrompt = (event: Event) => {
      event.preventDefault();

      if (isBannerSnoozed(INSTALL_BANNER_ID)) {
        setInstallPromptEvent(null);
        return;
      }

      bannerSettings.remove(`${INSTALL_BANNER_ID}.dismissed_at`);
      setDismissedBanners((state) => ({ ...state, install: false }));
      setInstallPromptEvent(event as DeferredBeforeInstallPromptEvent);
    };

    const handleAppInstalled = () => {
      setInstallPromptEvent(null);
    };

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
    window.addEventListener('appinstalled', handleAppInstalled);

    return () => {
      window.removeEventListener(
        'beforeinstallprompt',
        handleBeforeInstallPrompt,
      );
      window.removeEventListener('appinstalled', handleAppInstalled);
    };
  }, [android, standalone]);

  const handleInstall = useCallback(async () => {
    if (!installPromptEvent) {
      return;
    }

    await installPromptEvent.prompt();
    await installPromptEvent.userChoice;
    setInstallPromptEvent(null);
  }, [installPromptEvent]);

  const handleInstallClick = useCallback(() => {
    void handleInstall();
  }, [handleInstall]);

  const handleDismissInstallBanner = useCallback(() => {
    snoozeBanner(INSTALL_BANNER_ID);
    setDismissedBanners((state) => ({ ...state, install: true }));
    setInstallPromptEvent(null);
  }, []);

  const handleDismissIosBanner = useCallback(() => {
    snoozeBanner(IOS_BANNER_ID);
    setDismissedBanners((state) => ({ ...state, ios: true }));
  }, []);

  if (standalone) {
    return null;
  }

  if (ios) {
    if (dismissedBanners.ios) {
      return null;
    }

    return (
      <InstallBanner onDismiss={handleDismissIosBanner}>
        <h1 className='pwa-install-prompt__title'>
          <FormattedMessage
            id='pwa_install_prompt.install.message'
            defaultMessage='Install The Highlander app for faster access and a native-like experience.'
          />
        </h1>

        <p className='pwa-install-prompt__callout'>
          (
          <FormattedMessage {...messages.iosWarning} values={richTextValues} />)
        </p>

        <ol className='pwa-install-prompt__list'>
          {iosSteps.map((step) => (
            <li key={step.id}>
              <FormattedMessage {...step} values={richTextValues} />
            </li>
          ))}
        </ol>
      </InstallBanner>
    );
  }

  if (!android || !installPromptEvent || dismissedBanners.install) {
    return null;
  }

  return (
    <InstallBanner
      action={
        <button
          type='button'
          className='button button-tertiary'
          onClick={handleInstallClick}
        >
          <FormattedMessage
            id='pwa_install_prompt.install.action'
            defaultMessage='Install the app'
          />
        </button>
      }
      onDismiss={handleDismissInstallBanner}
    >
      <FormattedMessage
        id='pwa_install_prompt.install.message'
        defaultMessage='Install The Highlander app for faster access and a native-like experience.'
      />
    </InstallBanner>
  );
};
