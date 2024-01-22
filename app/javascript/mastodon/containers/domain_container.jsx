import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import { blockDomain, unblockDomain } from '../actions/domain_blocks';
import { openModal } from '../actions/modal';
import { Domain } from '../components/domain';

const messages = defineMessages({
  blockDomainConfirm: { id: 'confirmations.domain_block.confirm', defaultMessage: 'Block entire domain' },
});

const makeMapStateToProps = () => {
  const mapStateToProps = () => ({});

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { intl }) => ({
  onBlockDomain (domain) {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: <FormattedMessage id='confirmations.domain_block.message' defaultMessage='Are you really, really sure you want to block the entire {domain}? In most cases a few targeted blocks or mutes are sufficient and preferable. You will not see content from that domain in any public timelines or your notifications. Your followers from that domain will be removed.' values={{ domain: <strong>{domain}</strong> }} />,
        confirm: intl.formatMessage(messages.blockDomainConfirm),
        onConfirm: () => dispatch(blockDomain(domain)),
      },
    }));
  },

  onUnblockDomain (domain) {
    dispatch(unblockDomain(domain));
  },
});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Domain));
