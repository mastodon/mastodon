import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import Overlay from 'react-overlays/lib/Overlay';
import emojify from '../../emoji/emoji';
import classNames from 'classnames';
import ImmutablePropTypes from 'react-immutable-proptypes';
import detectPassiveEvents from 'detect-passive-events';
import escapeTextContentForBrowser from 'escape-html';

const messages = defineMessages({
  template: { id: 'template_button.label', defaultMessage: 'Insert template' },

});

const assetHost = process.env.CDN_HOST || '';

const listenerOptions = detectPassiveEvents.hasSupport ? { passive: true } : false;

@injectIntl
class TemplatePicker extends React.PureComponent {

  static propTypes = {
    custom_templates: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
    onClick: PropTypes.func.isRequired,
  };

  handleClick = e => {
    const { custom_templates, onClick } = this.props;
    onClick(custom_templates.get(e.currentTarget.getAttribute('data-index')));
  }

  render () {
    const { custom_templates, intl } = this.props;
    const { handleClick } = this;
    const title = intl.formatMessage(messages.template);

    return (
      <div className='template-picker'>
        <div className='template-picker-title'>{title}</div>
        <div className='template-picker-scroll'>
          <div className='template-picker-area'>
            {custom_templates.map((template, i) => {
              const content = template.get('content');
              const emojis = template.get('emojis').toJS().reduce((map, emoji) => {
                map[`:${emoji.shortcode}:`] = emoji;
                return map;
              }, {});

              const html = emojify(escapeTextContentForBrowser(content).replace(/\s*\r\n/g, '<br />'), emojis);

              return (
                <div
                  className='template-picker-template'
                  key={i}
                  data-index={i}
                  dangerouslySetInnerHTML={{ __html: html }}
                  onClick={handleClick}
                />
              );
            })}
          </div>
        </div>
      </div>
    );
  }
}

@injectIntl
class TemplatePickerMenu extends React.PureComponent {

  static propTypes = {
    custom_templates: ImmutablePropTypes.list,
    style: PropTypes.object,
    onPick: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
  };

  state = {
    placement: null,
  };

  handleDocumentClick = e => {
    if (this.node && !this.node.contains(e.target)) {
      this.props.onClose();
    }
  }

  componentDidMount () {
    document.addEventListener('click', this.handleDocumentClick, false);
    document.addEventListener('touchend', this.handleDocumentClick, listenerOptions);
  }

  componentWillUnmount () {
    document.removeEventListener('click', this.handleDocumentClick, false);
    document.removeEventListener('touchend', this.handleDocumentClick, listenerOptions);
  }

  setRef = c => {
    this.node = c;
  }

  handleClick = template => {
    this.props.onClose();
    this.props.onPick(template);
  }

  render () {
    const { style } = this.props;

    return (
      <div className='template-picker-dropdown__menu' style={style} ref={this.setRef}>
        <TemplatePicker
          custom_templates={this.props.custom_templates}
          onClick={this.handleClick}
        />
      </div>
    );
  }
}

export default @injectIntl
class TemplatePickerDropdown extends React.PureComponent {

  static propTypes = {
    custom_templates: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
    onPickTemplate: PropTypes.func.isRequired,
  };

  state = {
    active: false,
  };

  setRef = (c) => {
    this.dropdown = c;
  }

  onShowDropdown = ({ target }) => {
    this.setState({ active: true });

    const { top } = target.getBoundingClientRect();
    this.setState({ placement: top * 2 < innerHeight ? 'bottom' : 'top' });
  }

  onHideDropdown = () => {
    this.setState({ active: false });
  }

  onToggle = (e) => {
    if (!e.key || e.key === 'Enter') {
      if (this.state.active) {
        this.onHideDropdown();
      } else {
        this.onShowDropdown(e);
      }
    }
  }

  handleKeyDown = e => {
    if (e.key === 'Escape') {
      this.onHideDropdown();
    }
  }

  setTargetRef = c => {
    this.target = c;
  }

  findTarget = () => {
    return this.target;
  }

  render () {
    const { intl, onPickTemplate } = this.props;
    const title = intl.formatMessage(messages.template);
    const { active, placement } = this.state;

    return (
      <div className='template-picker-dropdown' onKeyDown={this.handleKeyDown}>
        <div ref={this.setTargetRef} className='emoji-button' title={title} aria-label={title} aria-expanded={active} role='button' onClick={this.onToggle} onKeyDown={this.onToggle} tabIndex={0}>
          <img
            className='emojione'
            alt='📋'
            src={`${assetHost}/emoji/1f4cb.svg`}
          />
        </div>

        <Overlay show={active} placement={placement} target={this.findTarget}>
          <TemplatePickerMenu
            custom_templates={this.props.custom_templates}
            onPick={onPickTemplate}
            onClose={this.onHideDropdown}
          />
        </Overlay>
      </div>
    );
  }
}
