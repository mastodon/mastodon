import React from 'react';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { domain } from 'mastodon/initial_state';
import { fetchServer } from 'mastodon/actions/server';

const mapStateToProps = state => ({
  message: state.getIn(['server', 'server', 'registrations', 'message']),
});

class ClosedRegistrationsModal extends ImmutablePureComponent {

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchServer());
  }

  render () {
    let closedRegistrationsMessage;

    if (this.props.message) {
      closedRegistrationsMessage = (
        <p
          className='prose'
          dangerouslySetInnerHTML={{ __html: this.props.message }}
        />
      );
    } else {
      closedRegistrationsMessage = (
        <p className='prose'>
          <FormattedMessage
            id='closed_registrations_modal.description'
            defaultMessage='Creating an account on {domain} is currently not possible, but please keep in mind that you do not need an account specifically on {domain} to use Mastodon.'
            values={{ domain: <strong>{domain}</strong> }}
          />
        </p>
      );
    }

    return (
      <div className='modal-root__modal interaction-modal'>
        <div className='interaction-modal__lead'>
          <h3><FormattedMessage id='closed_registrations_modal.title' defaultMessage='Signing up on Mastodon' /></h3>
          <p>
            <FormattedMessage
              id='closed_registrations_modal.preamble'
              defaultMessage='Mastodon is decentralized, so no matter where you create your account, you will be able to follow and interact with anyone on this server. You can even self-host it!'
            />
          </p>
        </div>

        <div className='interaction-modal__choices'>
          <div className='interaction-modal__choices__choice'>
            <h3><FormattedMessage id='interaction_modal.on_this_server' defaultMessage='On this server' /></h3>
            {closedRegistrationsMessage}
          </div>

          <div className='interaction-modal__choices__choice'>
            <h3><FormattedMessage id='interaction_modal.on_another_server' defaultMessage='On a different server' /></h3>
            <p className='prose'>
              <FormattedMessage
                id='closed_registrations.other_server_instructions'
                defaultMessage='Since Mastodon is decentralized, you can create an account on another server and still interact with this one.'
              />
            </p>
            <a href='https://joinmastodon.org/servers' className='button button--block'><FormattedMessage id='closed_registrations_modal.find_another_server' defaultMessage='Find another server' /></a>
          </div>
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps)(ClosedRegistrationsModal);
