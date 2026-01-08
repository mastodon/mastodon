import { useCallback } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { showAlert } from '@/mastodon/actions/alerts';
import { resetCompose, focusCompose } from '@/mastodon/actions/compose';
import { closeModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button';
import type { AnnualReport as AnnualReportData } from '@/mastodon/models/annual_report';
import { useAppDispatch } from '@/mastodon/store';

import { archetypeNames } from './archetype';
import styles from './index.module.scss';

const messages = defineMessages({
  share_message: {
    id: 'annual_report.summary.share_message',
    defaultMessage: 'I got the {archetype} archetype!',
  },
  share_on_mastodon: {
    id: 'annual_report.summary.share_on_mastodon',
    defaultMessage: 'Share on Mastodon',
  },
  share_elsewhere: {
    id: 'annual_report.summary.share_elsewhere',
    defaultMessage: 'Share elsewhere',
  },
  copy_link: {
    id: 'annual_report.summary.copy_link',
    defaultMessage: 'Copy link',
  },
  copied: {
    id: 'copy_icon_button.copied',
    defaultMessage: 'Copied to clipboard',
  },
});

export const ShareButton: FC<{ report: AnnualReportData }> = ({ report }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const handleShareClick = useCallback(() => {
    // Generate the share message.
    const archetypeName = intl.formatMessage(
      archetypeNames[report.data.archetype],
    );
    const shareLines = [
      intl.formatMessage(messages.share_message, {
        archetype: archetypeName,
      }),
    ];
    // Share URL is only available for schema version 2.
    if (report.schema_version === 2 && report.share_url) {
      shareLines.push(report.share_url);
    }
    shareLines.push(`#Wrapstodon${report.year}`);

    // Reset the composer and focus it with the share message, then close the modal.
    dispatch(resetCompose());
    dispatch(focusCompose(shareLines.join('\n\n')));
    dispatch(closeModal({ modalType: 'ANNUAL_REPORT', ignoreFocus: false }));
  }, [report, intl, dispatch]);

  const supportsNativeShare = 'share' in navigator;

  const handleSecondaryShare = useCallback(() => {
    if (report.schema_version === 2 && report.share_url) {
      if (supportsNativeShare) {
        void navigator.share({
          url: report.share_url,
        });
      } else {
        void navigator.clipboard.writeText(report.share_url);
        dispatch(showAlert({ message: messages.copied }));
      }
    }
  }, [report, supportsNativeShare, dispatch]);

  return (
    <div className={styles.shareButtonWrapper}>
      <Button
        text={intl.formatMessage(messages.share_on_mastodon)}
        onClick={handleShareClick}
      />
      <Button
        plain
        className={styles.secondaryShareButton}
        text={intl.formatMessage(
          supportsNativeShare ? messages.share_elsewhere : messages.copy_link,
        )}
        onClick={handleSecondaryShare}
      />
    </div>
  );
};
