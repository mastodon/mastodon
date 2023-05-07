import React from 'react';
import IconButton from './icon_button';
import { InjectedIntl, defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  unblockDomain: { id: 'account.unblock_domain', defaultMessage: 'Unblock domain {domain}' },
});

type Props = {
  domain: string;
  onUnblockDomain: (domain: string) => void;
  intl: InjectedIntl;
}
class Domain extends ImmutablePureComponent<Props> {

  handleDomainUnblock = () => {
    this.props.onUnblockDomain(this.props.domain);
  };

  render () {
    const { domain, intl } = this.props;

    return (
      <div className='domain'>
        <div className='domain__wrapper'>
          <span className='domain__domain-name'>
            <strong>{domain}</strong>
          </span>

          <div className='domain__buttons'>
            <IconButton active icon='unlock' title={intl.formatMessage(messages.unblockDomain, { domain })} onClick={this.handleDomainUnblock} />
          </div>
        </div>
      </div>
    );
  }

}

export default injectIntl(Domain);
