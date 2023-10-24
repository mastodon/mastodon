import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { ReactComponent as CloseIcon } from '@material-symbols/svg-600/outlined/close.svg';
import escapeTextContentForBrowser from 'escape-html';

import { closeModal } from 'flavours/glitch/actions/modal';
import { IconButton } from 'flavours/glitch/components/icon_button';
import InlineAccount from 'flavours/glitch/components/inline_account';
import MediaAttachments from 'flavours/glitch/components/media_attachments';
import { RelativeTimestamp } from 'flavours/glitch/components/relative_timestamp';
import emojify from 'flavours/glitch/features/emoji/emoji';

const mapStateToProps = (state, { statusId }) => ({
  language: state.getIn(['statuses', statusId, 'language']),
  versions: state.getIn(['history', statusId, 'items']),
});

const mapDispatchToProps = dispatch => ({

  onClose() {
    dispatch(closeModal({
      modalType: undefined,
      ignoreFocus: false,
    }));
  },

});

class CompareHistoryModal extends PureComponent {

  static propTypes = {
    onClose: PropTypes.func.isRequired,
    index: PropTypes.number.isRequired,
    statusId: PropTypes.string.isRequired,
    language: PropTypes.string.isRequired,
    versions: ImmutablePropTypes.list.isRequired,
  };

  render () {
    const { index, versions, language, onClose } = this.props;
    const currentVersion = versions.get(index);

    const emojiMap = currentVersion.get('emojis').reduce((obj, emoji) => {
      obj[`:${emoji.get('shortcode')}:`] = emoji.toJS();
      return obj;
    }, {});

    const content = { __html: emojify(currentVersion.get('content'), emojiMap) };
    const spoilerContent = { __html: emojify(escapeTextContentForBrowser(currentVersion.get('spoiler_text')), emojiMap) };

    const formattedDate = <RelativeTimestamp timestamp={currentVersion.get('created_at')} short={false} />;
    const formattedName = <InlineAccount accountId={currentVersion.get('account')} />;

    const label = currentVersion.get('original') ? (
      <FormattedMessage id='status.history.created' defaultMessage='{name} created {date}' values={{ name: formattedName, date: formattedDate }} />
    ) : (
      <FormattedMessage id='status.history.edited' defaultMessage='{name} edited {date}' values={{ name: formattedName, date: formattedDate }} />
    );

    return (
      <div className='modal-root__modal compare-history-modal'>
        <div className='report-modal__target'>
          <IconButton className='report-modal__close' icon='times' iconComponent={CloseIcon} onClick={onClose} size={20} />
          {label}
        </div>

        <div className='compare-history-modal__container'>
          <div className='status__content'>
            {currentVersion.get('spoiler_text').length > 0 && (
              <>
                <div className='translate' dangerouslySetInnerHTML={spoilerContent} lang={language} />
                <hr />
              </>
            )}

            <div className='status__content__text status__content__text--visible translate' dangerouslySetInnerHTML={content} lang={language} />

            {!!currentVersion.get('poll') && (
              <div className='poll'>
                <ul>
                  {currentVersion.getIn(['poll', 'options']).map(option => (
                    <li key={option.get('title')}>
                      <span className='poll__input disabled' />

                      <span
                        className='poll__option__text translate'
                        dangerouslySetInnerHTML={{ __html: emojify(escapeTextContentForBrowser(option.get('title')), emojiMap) }}
                        lang={language}
                      />
                    </li>
                  ))}
                </ul>
              </div>
            )}

            <MediaAttachments status={currentVersion} lang={language} />
          </div>
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(CompareHistoryModal);
