import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { AvatarOverlay } from '../../../components/avatar_overlay';
import { DisplayName } from '../../../components/display_name';
import { Link } from 'react-router-dom';

export default class MovedNote extends ImmutablePureComponent {

  static propTypes = {
    from: ImmutablePropTypes.map.isRequired,
    to: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const { from, to } = this.props;

    return (
      <div className='moved-account-banner'>
        <div className='moved-account-banner__message'>
          <FormattedMessage id='account.moved_to' defaultMessage='{name} has indicated that their new account is now:' values={{ name: <bdi><strong dangerouslySetInnerHTML={{ __html: from.get('display_name_html') }} /></bdi> }} />
        </div>

        <div className='moved-account-banner__action'>
          <Link to={`/@${to.get('acct')}`} className='detailed-status__display-name'>
            <div className='detailed-status__display-avatar'><AvatarOverlay account={to} friend={from} /></div>
            <DisplayName account={to} />
          </Link>

          <Link to={`/@${to.get('acct')}`} className='button'><FormattedMessage id='account.go_to_profile' defaultMessage='Go to profile' /></Link>
        </div>
      </div>
    );
  }

}
