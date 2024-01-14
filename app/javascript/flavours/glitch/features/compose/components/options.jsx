import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { ReactComponent as AttachFileIcon } from '@material-symbols/svg-600/outlined/attach_file.svg';
import { ReactComponent as BrushIcon } from '@material-symbols/svg-600/outlined/brush.svg';
import { ReactComponent as CodeIcon } from '@material-symbols/svg-600/outlined/code.svg';
import { ReactComponent as DescriptionIcon } from '@material-symbols/svg-600/outlined/description.svg';
import { ReactComponent as InsertChartIcon } from '@material-symbols/svg-600/outlined/insert_chart.svg';
import { ReactComponent as MarkdownIcon } from '@material-symbols/svg-600/outlined/markdown.svg';
import { ReactComponent as MoreHorizIcon } from '@material-symbols/svg-600/outlined/more_horiz.svg';
import { ReactComponent as UploadFileIcon } from '@material-symbols/svg-600/outlined/upload_file.svg';
import Toggle from 'react-toggle';

import { IconButton } from 'flavours/glitch/components/icon_button';
import { pollLimits } from 'flavours/glitch/initial_state';

import DropdownContainer from '../containers/dropdown_container';
import LanguageDropdown from '../containers/language_dropdown_container';
import PrivacyDropdownContainer from '../containers/privacy_dropdown_container';

import TextIconButton from './text_icon_button';

const messages = defineMessages({
  advanced_options_icon_title: {
    defaultMessage: 'Advanced options',
    id: 'advanced_options.icon_title',
  },
  attach: {
    defaultMessage: 'Attach...',
    id: 'compose.attach',
  },
  content_type: {
    defaultMessage: 'Content type',
    id: 'content-type.change',
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

const mapStateToProps = (state, { name }) => ({
  checked: state.getIn(['compose', 'advanced_options', name]),
});

class ToggleOptionImpl extends ImmutablePureComponent {

  static propTypes = {
    name: PropTypes.string.isRequired,
    checked: PropTypes.bool,
    onChangeAdvancedOption: PropTypes.func.isRequired,
  };

  handleChange = () => {
    this.props.onChangeAdvancedOption(this.props.name);
  };

  render() {
    const { meta, text, checked } = this.props;

    return (
      <>
        <Toggle checked={checked} onChange={this.handleChange} />

        <div className='privacy-dropdown__option__content'>
          <strong>{text}</strong>
          {meta}
        </div>
      </>
    );
  }

}

const ToggleOption = connect(mapStateToProps)(ToggleOptionImpl);

class ComposerOptions extends ImmutablePureComponent {

  static propTypes = {
    acceptContentTypes: PropTypes.string,
    advancedOptions: ImmutablePropTypes.map,
    disabled: PropTypes.bool,
    allowMedia: PropTypes.bool,
    allowPoll: PropTypes.bool,
    hasPoll: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    onChangeAdvancedOption: PropTypes.func.isRequired,
    onChangeContentType: PropTypes.func.isRequired,
    onTogglePoll: PropTypes.func.isRequired,
    onDoodleOpen: PropTypes.func.isRequired,
    onToggleSpoiler: PropTypes.func,
    onUpload: PropTypes.func.isRequired,
    contentType: PropTypes.string,
    resetFileKey: PropTypes.number,
    spoiler: PropTypes.bool,
    showContentTypeChoice: PropTypes.bool,
    isEditing: PropTypes.bool,
  };

  handleChangeFiles = ({ target: { files } }) => {
    const { onUpload } = this.props;
    if (files.length) {
      onUpload(files);
    }
  };

  handleClickAttach = (name) => {
    const { fileElement } = this;
    const { onDoodleOpen } = this.props;

    switch (name) {
    case 'upload':
      if (fileElement) {
        fileElement.click();
      }
      return;
    case 'doodle':
      onDoodleOpen();
      return;
    }
  };

  handleRefFileElement = (fileElement) => {
    this.fileElement = fileElement;
  };

  renderToggleItemContents = (item) => {
    const { onChangeAdvancedOption } = this.props;
    const { name, meta, text } = item;

    return <ToggleOption name={name} text={text} meta={meta} onChangeAdvancedOption={onChangeAdvancedOption} />;
  };

  render () {
    const {
      acceptContentTypes,
      advancedOptions,
      contentType,
      disabled,
      allowMedia,
      allowPoll,
      hasPoll,
      onChangeAdvancedOption,
      onChangeContentType,
      onTogglePoll,
      onToggleSpoiler,
      resetFileKey,
      spoiler,
      showContentTypeChoice,
      isEditing,
      intl: { formatMessage },
    } = this.props;

    const contentTypeItems = {
      plain: {
        icon: 'file-text',
        iconComponent: DescriptionIcon,
        name: 'text/plain',
        text: formatMessage(messages.plain),
      },
      html: {
        icon: 'code',
        iconComponent: CodeIcon,
        name: 'text/html',
        text: formatMessage(messages.html),
      },
      markdown: {
        icon: 'arrow-circle-down',
        iconComponent: MarkdownIcon,
        name: 'text/markdown',
        text: formatMessage(messages.markdown),
      },
    };

    //  The result.
    return (
      <div className='compose-form__buttons'>
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
        <DropdownContainer
          disabled={disabled || !allowMedia}
          icon='paperclip'
          iconComponent={AttachFileIcon}
          items={[
            {
              icon: 'cloud-upload',
              iconComponent: UploadFileIcon,
              name: 'upload',
              text: formatMessage(messages.upload),
            },
            {
              icon: 'paint-brush',
              iconComponent: BrushIcon,
              name: 'doodle',
              text: formatMessage(messages.doodle),
            },
          ]}
          onChange={this.handleClickAttach}
          title={formatMessage(messages.attach)}
        />
        {!!pollLimits && (
          <IconButton
            active={hasPoll}
            disabled={disabled || !allowPoll}
            icon='tasks'
            iconComponent={InsertChartIcon}
            inverted
            onClick={onTogglePoll}
            size={18}
            style={{
              height: null,
              lineHeight: null,
            }}
            title={formatMessage(hasPoll ? messages.remove_poll : messages.add_poll)}
          />
        )}
        <PrivacyDropdownContainer disabled={disabled || isEditing} />
        {showContentTypeChoice && (
          <DropdownContainer
            disabled={disabled}
            icon={(contentTypeItems[contentType.split('/')[1]] || {}).icon}
            iconComponent={(contentTypeItems[contentType.split('/')[1]] || {}).iconComponent}
            items={[
              contentTypeItems.plain,
              contentTypeItems.html,
              contentTypeItems.markdown,
            ]}
            onChange={onChangeContentType}
            title={formatMessage(messages.content_type)}
            value={contentType}
          />
        )}
        {onToggleSpoiler && (
          <TextIconButton
            active={spoiler}
            ariaControls='cw-spoiler-input'
            label='CW'
            onClick={onToggleSpoiler}
            title={formatMessage(messages.spoiler)}
          />
        )}
        <LanguageDropdown />
        <DropdownContainer
          disabled={disabled || isEditing}
          icon='ellipsis-h'
          iconComponent={MoreHorizIcon}
          items={advancedOptions ? [
            {
              meta: formatMessage(messages.local_only_long),
              name: 'do_not_federate',
              text: formatMessage(messages.local_only_short),
            },
            {
              meta: formatMessage(messages.threaded_mode_long),
              name: 'threaded_mode',
              text: formatMessage(messages.threaded_mode_short),
            },
          ] : null}
          onChange={onChangeAdvancedOption}
          renderItemContents={this.renderToggleItemContents}
          title={formatMessage(messages.advanced_options_icon_title)}
          closeOnChange={false}
        />
      </div>
    );
  }

}

export default injectIntl(ComposerOptions);
