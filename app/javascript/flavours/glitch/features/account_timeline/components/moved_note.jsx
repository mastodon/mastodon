import { FormattedMessage } from 'react-intl';

import { withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';


import TripIcon from '@/material-icons/400-24px/trip.svg?react';
import { Icon } from 'flavours/glitch/components/icon';
import { WithRouterPropTypes } from 'flavours/glitch/utils/react_router';

import { AvatarOverlay } from '../../../components/avatar_overlay';
import { DisplayName } from '../../../components/display_name';

class MovedNote extends ImmutablePureComponent {

  static propTypes = {
    from: ImmutablePropTypes.map.isRequired,
    to: ImmutablePropTypes.map.isRequired,
    ...WithRouterPropTypes,
  };

  handleAccountClick = e => {
    if (e.button === 0) {
      e.preventDefault();
      this.props.history.push(`/@${this.props.to.get('acct')}`);
    }

    e.stopPropagation();
  };

  render () {
    const { from, to } = this.props;
    const displayNameHtml = { __html: from.get('display_name_html') };

    return (
      <div className='account__moved-note'>
        <div className='account__moved-note__message'>
          <div className='account__moved-note__icon-wrapper'><Icon id='suitcase' className='account__moved-note__icon' icon={TripIcon} /></div>
          <FormattedMessage id='account.moved_to' defaultMessage='{name} has indicated that their new account is now:' values={{ name: <bdi><strong dangerouslySetInnerHTML={displayNameHtml} /></bdi> }} />
        </div>

        <a href={to.get('url')} onClick={this.handleAccountClick} className='detailed-status__display-name'>
          <div className='detailed-status__display-avatar'><AvatarOverlay account={to} friend={from} /></div>
          <DisplayName account={to} />
        </a>
      </div>
    );
  }

}

export default withRouter(MovedNote);
