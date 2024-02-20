import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { AvatarOverlay } from '../../../components/avatar_overlay';
import { DisplayName } from '../../../components/display_name';
import { Permalink } from '../../../components/permalink';

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
          <Permalink to={`/@${to.get('acct')}`} href={to.get('url')} className='detailed-status__display-name'>
            <div className='detailed-status__display-avatar'><AvatarOverlay account={to} friend={from} /></div>
            <DisplayName account={to} />
          </Permalink>

          <Permalink to={`/@${to.get('acct')}`} href={to.get('url')} className='button'><FormattedMessage id='account.go_to_profile' defaultMessage='Go to profile' /></Permalink>
        </div>
      </div>
    );
  }

}
