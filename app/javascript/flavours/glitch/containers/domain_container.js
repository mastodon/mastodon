import React from 'react';
import { connect } from 'react-redux';
import { blockDomain, unblockDomain } from '../actions/domain_blocks';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Domain from '../components/domain';
import { openModal } from '../actions/modal';

const messages = defineMessages({
  blockDomainConfirm: { id: 'confirmations.domain_block.confirm', defaultMessage: 'Block entire domain' },
});

const makeMapStateToProps = () => {
  const mapStateToProps = (state, { }) => ({
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { intl }) => ({
  onBlockDomain (domain) {
    dispatch(openModal('CONFIRM', {
      message: <FormattedMessage id='confirmations.domain_block.message' defaultMessage='Are you really, really sure you want to block the entire {domain}? In most cases a few targeted blocks or mutes are sufficient and preferable.' values={{ domain: <strong>{domain}</strong> }} />,
      confirm: intl.formatMessage(messages.blockDomainConfirm),
      onConfirm: () => dispatch(blockDomain(domain)),
    }));
  },

  onUnblockDomain (domain) {
    dispatch(unblockDomain(domain));
  },
});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Domain));
