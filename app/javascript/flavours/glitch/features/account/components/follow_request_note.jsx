import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { Icon } from 'flavours/glitch/components/icon';

export default class FollowRequestNote extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const { account, onAuthorize, onReject } = this.props;

    return (
      <div className='follow-request-banner'>
        <div className='follow-request-banner__message'>
          <FormattedMessage id='account.requested_follow' defaultMessage='{name} has requested to follow you' values={{ name: <bdi><strong dangerouslySetInnerHTML={{ __html: account.get('display_name_html') }} /></bdi> }} />
        </div>

        <div className='follow-request-banner__action'>
          <button type='button' className='button button-tertiary button--confirmation' onClick={onAuthorize}>
            <Icon id='check' fixedWidth />
            <FormattedMessage id='follow_request.authorize' defaultMessage='Authorize' />
          </button>

          <button type='button' className='button button-tertiary button--destructive' onClick={onReject}>
            <Icon id='times' fixedWidth />
            <FormattedMessage id='follow_request.reject' defaultMessage='Reject' />
          </button>
        </div>
      </div>
    );
  }

}
