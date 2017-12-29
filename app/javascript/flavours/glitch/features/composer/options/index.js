//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import {
  FormattedMessage,
  defineMessages,
} from 'react-intl';
import spring from 'react-motion/lib/spring';

//  Components.
import IconButton from 'flavours/glitch/components/icon_button';
import TextIconButton from 'flavours/glitch/components/text_icon_button';
import Dropdown from './dropdown';

//  Utils.
import Motion from 'flavours/glitch/util/optional_motion';
import {
  assignHandlers,
  hiddenComponent,
} from 'flavours/glitch/util/react_helpers';

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
  local_only_long: {
    defaultMessage: 'Do not post to other instances',
    id: 'advanced-options.local-only.long',
  },
  local_only_short: {
    defaultMessage: 'Local-only',
    id: 'advanced-options.local-only.short',
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
  sensitive: {
    defaultMessage: 'Mark media as sensitive',
    id: 'compose_form.sensitive',
  },
  spoiler: {
    defaultMessage: 'Hide text behind warning',
    id: 'compose_form.spoiler',
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
});

//  Handlers.
const handlers = {

  //  Handles file selection.
  changeFiles ({ target: { files } }) {
    const { onUpload } = this.props;
    if (files.length && onUpload) {
      onUpload(files);
    }
  },

  //  Handles attachment clicks.
  clickAttach (name) {
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
  },

  //  Handles a ref to the file input.
  refFileElement (fileElement) {
    this.fileElement = fileElement;
  },
};

//  The component.
export default class ComposerOptions extends React.PureComponent {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);

    //  Instance variables.
    this.fileElement = null;
  }

  //  Rendering.
  render () {
    const {
      changeFiles,
      clickAttach,
      refFileElement,
    } = this.handlers;
    const {
      acceptContentTypes,
      disabled,
      doNotFederate,
      full,
      hasMedia,
      intl,
      onChangeSensitivity,
      onChangeVisibility,
      onModalClose,
      onModalOpen,
      onToggleAdvancedOption,
      privacy,
      resetFileKey,
      sensitive,
      spoiler,
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
        icon: 'unlock-alt',
        meta: <FormattedMessage {...messages.unlisted_long} />,
        name: 'unlisted',
        text: <FormattedMessage {...messages.unlisted_short} />,
      },
    };

    //  The result.
    return (
      <div className='composer--options'>
        <input
          accept={acceptContentTypes}
          disabled={disabled || full}
          key={resetFileKey}
          onChange={changeFiles}
          ref={refFileElement}
          type='file'
          {...hiddenComponent}
        />
        <Dropdown
          disabled={disabled || full}
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
          onChange={clickAttach}
          onModalClose={onModalClose}
          onModalOpen={onModalOpen}
          title={messages.attach}
        />
        <Motion
          defaultStyle={{ scale: 0.87 }}
          style={{
            scale: spring(hasMedia ? 1 : 0.87, {
              stiffness: 200,
              damping: 3,
            }),
          }}
        >
          {({ scale }) => (
            <div
              style={{
                display: hasMedia ? null : 'none',
                transform: `scale(${scale})`,
              }}
            >
              <IconButton
                active={sensitive}
                className='sensitive'
                disabled={spoiler}
                icon={sensitive ? 'eye-slash' : 'eye'}
                inverted
                onClick={onChangeSensitivity}
                size={18}
                style={{
                  height: null,
                  lineHeight: null,
                }}
                title={intl.formatMessage(messages.sensitive)}
              />
            </div>
          )}
        </Motion>
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
        <TextIconButton
          active={spoiler}
          ariaControls='glitch.composer.spoiler.input'
          label='CW'
          title={intl.formatMessage(messages.spoiler)}
        />
        <Dropdown
          active={doNotFederate}
          disabled={disabled}
          icon='home'
          items={[
            {
              meta: <FormattedMessage {...messages.local_only_long} />,
              name: 'do_not_federate',
              on: doNotFederate,
              text: <FormattedMessage {...messages.local_only_short} />,
            },
          ]}
          onChange={onToggleAdvancedOption}
          onModalClose={onModalClose}
          onModalOpen={onModalOpen}
          title={intl.formatMessage(messages.advanced_options_icon_title)}
        />
      </div>
    );
  }

}

//  Props.
ComposerOptions.propTypes = {
  acceptContentTypes: PropTypes.string,
  disabled: PropTypes.bool,
  doNotFederate: PropTypes.bool,
  full: PropTypes.bool,
  hasMedia: PropTypes.bool,
  intl: PropTypes.object.isRequired,
  onChangeSensitivity: PropTypes.func,
  onChangeVisibility: PropTypes.func,
  onDoodleOpen: PropTypes.func,
  onModalClose: PropTypes.func,
  onModalOpen: PropTypes.func,
  onToggleAdvancedOption: PropTypes.func,
  onUpload: PropTypes.func,
  privacy: PropTypes.string,
  resetFileKey: PropTypes.string,
  sensitive: PropTypes.bool,
  spoiler: PropTypes.bool,
};
