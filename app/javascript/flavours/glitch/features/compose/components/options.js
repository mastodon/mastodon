//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import spring from 'react-motion/lib/spring';

//  Components.
import IconButton from 'flavours/glitch/components/icon_button';
import TextIconButton from './text_icon_button';
import Dropdown from './dropdown';
import ImmutablePureComponent from 'react-immutable-pure-component';

//  Utils.
import Motion from 'flavours/glitch/util/optional_motion';
import { pollLimits } from 'flavours/glitch/util/initial_state';

//  Messages.
const messages = defineMessages({
  advanced_options_icon_title: {
    defaultMessage: 'Advanced options',
    id: 'advanced_options.icon_title',
  },
  attach: {
    defaultMessage: 'Attach...',
    id: 'compose.attach',
  },
  change_privacy: {
    defaultMessage: 'Adjust status privacy',
    id: 'privacy.change',
  },
  content_type: {
    defaultMessage: 'Content type',
    id: 'content-type.change',
  },
  direct_long: {
    defaultMessage: 'Post to mentioned users only',
    id: 'privacy.direct.long',
  },
  direct_short: {
    defaultMessage: 'Direct',
    id: 'privacy.direct.short',
  },
  doodle: {
    defaultMessage: 'Draw something',
    id: 'compose.attach.doodle',
  },
  html: {
    defaultMessage: 'HTML',
    id: 'compose.content-type.html',
  },
  local_only_long: {
    defaultMessage: 'Do not post to other instances',
    id: 'advanced_options.local-only.long',
  },
  local_only_short: {
    defaultMessage: 'Local-only',
    id: 'advanced_options.local-only.short',
  },
  markdown: {
    defaultMessage: 'Markdown',
    id: 'compose.content-type.markdown',
  },
  plain: {
    defaultMessage: 'Plain text',
    id: 'compose.content-type.plain',
  },
  private_long: {
    defaultMessage: 'Post to followers only',
    id: 'privacy.private.long',
  },
  private_short: {
    defaultMessage: 'Followers-only',
    id: 'privacy.private.short',
  },
  public_long: {
    defaultMessage: 'Post to public timelines',
    id: 'privacy.public.long',
  },
  public_short: {
    defaultMessage: 'Public',
    id: 'privacy.public.short',
  },
  spoiler: {
    defaultMessage: 'Hide text behind warning',
    id: 'compose_form.spoiler',
  },
  threaded_mode_long: {
    defaultMessage: 'Automatically opens a reply on posting',
    id: 'advanced_options.threaded_mode.long',
  },
  threaded_mode_short: {
    defaultMessage: 'Threaded mode',
    id: 'advanced_options.threaded_mode.short',
  },
  unlisted_long: {
    defaultMessage: 'Do not show in public timelines',
    id: 'privacy.unlisted.long',
  },
  unlisted_short: {
    defaultMessage: 'Unlisted',
    id: 'privacy.unlisted.short',
  },
  upload: {
    defaultMessage: 'Upload a file',
    id: 'compose.attach.upload',
  },
  add_poll: {
    defaultMessage: 'Add a poll',
    id: 'poll_button.add_poll',
  },
  remove_poll: {
    defaultMessage: 'Remove poll',
    id: 'poll_button.remove_poll',
  },
});

export default @injectIntl
class ComposerOptions extends ImmutablePureComponent {

  static propTypes = {
    acceptContentTypes: PropTypes.string,
    advancedOptions: ImmutablePropTypes.map,
    disabled: PropTypes.bool,
    allowMedia: PropTypes.bool,
    hasMedia: PropTypes.bool,
    allowPoll: PropTypes.bool,
    hasPoll: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    onChangeAdvancedOption: PropTypes.func,
    onChangeVisibility: PropTypes.func,
    onChangeContentType: PropTypes.func,
    onTogglePoll: PropTypes.func,
    onDoodleOpen: PropTypes.func,
    onModalClose: PropTypes.func,
    onModalOpen: PropTypes.func,
    onToggleSpoiler: PropTypes.func,
    onUpload: PropTypes.func,
    privacy: PropTypes.string,
    contentType: PropTypes.string,
    resetFileKey: PropTypes.number,
    spoiler: PropTypes.bool,
    showContentTypeChoice: PropTypes.bool,
  };

  //  Handles file selection.
  handleChangeFiles = ({ target: { files } }) => {
    const { onUpload } = this.props;
    if (files.length && onUpload) {
      onUpload(files);
    }
  }

  //  Handles attachment clicks.
  handleClickAttach = (name) => {
    const { fileElement } = this;
    const { onDoodleOpen } = this.props;

    //  We switch over the name of the option.
    switch (name) {
    case 'upload':
      if (fileElement) {
        fileElement.click();
      }
      return;
    case 'doodle':
      if (onDoodleOpen) {
        onDoodleOpen();
      }
      return;
    }
  }

  //  Handles a ref to the file input.
  handleRefFileElement = (fileElement) => {
    this.fileElement = fileElement;
  }

  //  Rendering.
  render () {
    const {
      acceptContentTypes,
      advancedOptions,
      contentType,
      disabled,
      allowMedia,
      hasMedia,
      allowPoll,
      hasPoll,
      intl,
      onChangeAdvancedOption,
      onChangeContentType,
      onChangeVisibility,
      onTogglePoll,
      onModalClose,
      onModalOpen,
      onToggleSpoiler,
      privacy,
      resetFileKey,
      spoiler,
      showContentTypeChoice,
    } = this.props;

    //  We predefine our privacy items so that we can easily pick the
    //  dropdown icon later.
    const privacyItems = {
      direct: {
        icon: 'envelope',
        meta: <FormattedMessage {...messages.direct_long} />,
        name: 'direct',
        text: <FormattedMessage {...messages.direct_short} />,
      },
      private: {
        icon: 'lock',
        meta: <FormattedMessage {...messages.private_long} />,
        name: 'private',
        text: <FormattedMessage {...messages.private_short} />,
      },
      public: {
        icon: 'globe',
        meta: <FormattedMessage {...messages.public_long} />,
        name: 'public',
        text: <FormattedMessage {...messages.public_short} />,
      },
      unlisted: {
        icon: 'unlock',
        meta: <FormattedMessage {...messages.unlisted_long} />,
        name: 'unlisted',
        text: <FormattedMessage {...messages.unlisted_short} />,
      },
    };

    const contentTypeItems = {
      plain: {
        icon: 'file-text',
        name: 'text/plain',
        text: <FormattedMessage {...messages.plain} />,
      },
      html: {
        icon: 'code',
        name: 'text/html',
        text: <FormattedMessage {...messages.html} />,
      },
      markdown: {
        icon: 'arrow-circle-down',
        name: 'text/markdown',
        text: <FormattedMessage {...messages.markdown} />,
      },
    };

    //  The result.
    return (
      <div className='composer--options'>
        <input
          accept={acceptContentTypes}
          disabled={disabled || !allowMedia}
          key={resetFileKey}
          onChange={this.handleChangeFiles}
          ref={this.handleRefFileElement}
          type='file'
          multiple
          style={{ display: 'none' }}
        />
        <Dropdown
          disabled={disabled || !allowMedia}
          icon='paperclip'
          items={[
            {
              icon: 'cloud-upload',
              name: 'upload',
              text: <FormattedMessage {...messages.upload} />,
            },
            {
              icon: 'paint-brush',
              name: 'doodle',
              text: <FormattedMessage {...messages.doodle} />,
            },
          ]}
          onChange={this.handleClickAttach}
          onModalClose={onModalClose}
          onModalOpen={onModalOpen}
          title={intl.formatMessage(messages.attach)}
        />
        {!!pollLimits && (
          <IconButton
            active={hasPoll}
            disabled={disabled || !allowPoll}
            icon='tasks'
            inverted
            onClick={onTogglePoll}
            size={18}
            style={{
              height: null,
              lineHeight: null,
            }}
            title={intl.formatMessage(hasPoll ? messages.remove_poll : messages.add_poll)}
          />
        )}
        <hr />
        <Dropdown
          disabled={disabled}
          icon={(privacyItems[privacy] || {}).icon}
          items={[
            privacyItems.public,
            privacyItems.unlisted,
            privacyItems.private,
            privacyItems.direct,
          ]}
          onChange={onChangeVisibility}
          onModalClose={onModalClose}
          onModalOpen={onModalOpen}
          title={intl.formatMessage(messages.change_privacy)}
          value={privacy}
        />
        {showContentTypeChoice && (
          <Dropdown
            disabled={disabled}
            icon={(contentTypeItems[contentType.split('/')[1]] || {}).icon}
            items={[
              contentTypeItems.plain,
              contentTypeItems.html,
              contentTypeItems.markdown,
            ]}
            onChange={onChangeContentType}
            onModalClose={onModalClose}
            onModalOpen={onModalOpen}
            title={intl.formatMessage(messages.content_type)}
            value={contentType}
          />
        )}
        {onToggleSpoiler && (
          <TextIconButton
            active={spoiler}
            ariaControls='glitch.composer.spoiler.input'
            label='CW'
            onClick={onToggleSpoiler}
            title={intl.formatMessage(messages.spoiler)}
          />
        )}
        <Dropdown
          active={advancedOptions && advancedOptions.some(value => !!value)}
          disabled={disabled}
          icon='ellipsis-h'
          items={advancedOptions ? [
            {
              meta: <FormattedMessage {...messages.local_only_long} />,
              name: 'do_not_federate',
              on: advancedOptions.get('do_not_federate'),
              text: <FormattedMessage {...messages.local_only_short} />,
            },
            {
              meta: <FormattedMessage {...messages.threaded_mode_long} />,
              name: 'threaded_mode',
              on: advancedOptions.get('threaded_mode'),
              text: <FormattedMessage {...messages.threaded_mode_short} />,
            },
          ] : null}
          onChange={onChangeAdvancedOption}
          onModalClose={onModalClose}
          onModalOpen={onModalOpen}
          title={intl.formatMessage(messages.advanced_options_icon_title)}
        />
      </div>
    );
  }

}
