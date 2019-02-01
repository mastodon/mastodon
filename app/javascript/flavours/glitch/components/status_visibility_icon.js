//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  public: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  private: { id: 'privacy.private.short', defaultMessage: 'Followers-only' },
  direct: { id: 'privacy.direct.short', defaultMessage: 'Direct' },
});

@injectIntl
export default class VisibilityIcon extends ImmutablePureComponent {

  static propTypes = {
    visibility: PropTypes.string,
    intl: PropTypes.object.isRequired,
    withLabel: PropTypes.bool,
  };

  render() {
    const { withLabel, visibility, intl } = this.props;

    const visibilityClass = {
      public: 'globe',
      unlisted: 'unlock',
      private: 'lock',
      direct: 'envelope',
    }[visibility];

    const label = intl.formatMessage(messages[visibility]);

    const icon = (<i
      className={`status__visibility-icon fa fa-fw fa-${visibilityClass}`}
      title={label}
      aria-hidden='true'
    />);

    if (withLabel) {
      return (<span style={{ whiteSpace: 'nowrap' }}>{icon} {label}</span>);
    } else {
      return icon;
    }
  }

}
