//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages } from 'react-intl';
import classNames from 'classnames';

//  Actions.
import { openModal } from 'flavours/glitch/actions/modal';
import {
  changeSearch,
  clearSearch,
  showSearch,
  submitSearch,
} from 'flavours/glitch/actions/search';
import { cycleElefriendCompose } from 'flavours/glitch/actions/compose';

//  Components.
import Composer from 'flavours/glitch/features/composer';
import DrawerAccount from './account';
import DrawerHeader from './header';
import DrawerResults from './results';
import DrawerSearch from './search';

//  Utils.
import { me, mascot } from 'flavours/glitch/util/initial_state';
import { wrap } from 'flavours/glitch/util/redux_helpers';

//  Messages.
const messages = defineMessages({
  compose: { id: 'navigation_bar.compose', defaultMessage: 'Compose new toot' },
});

//  State mapping.
const mapStateToProps = state => ({
  account: state.getIn(['accounts', me]),
  columns: state.getIn(['settings', 'columns']),
  elefriend: state.getIn(['compose', 'elefriend']),
  results: state.getIn(['search', 'results']),
  searchHidden: state.getIn(['search', 'hidden']),
  searchValue: state.getIn(['search', 'value']),
  submitted: state.getIn(['search', 'submitted']),
  unreadNotifications: state.getIn(['notifications', 'unread']),
  showNotificationsBadge: state.getIn(['local_settings', 'notifications', 'tab_badge']),
});

//  Dispatch mapping.
const mapDispatchToProps = (dispatch, { intl }) => ({
  onChange (value) {
    dispatch(changeSearch(value));
  },
  onClear () {
    dispatch(clearSearch());
  },
  onClickElefriend () {
    dispatch(cycleElefriendCompose());
  },
  onShow () {
    dispatch(showSearch());
  },
  onSubmit () {
    dispatch(submitSearch());
  },
  onOpenSettings (e) {
    e.preventDefault();
    e.stopPropagation();
    dispatch(openModal('SETTINGS', {}));
  },
});

//  The component.
class Drawer extends React.Component {

  //  Constructor.
  constructor (props) {
    super(props);
  }

  //  Rendering.
  render () {
    const {
      account,
      columns,
      elefriend,
      intl,
      multiColumn,
      onChange,
      onClear,
      onClickElefriend,
      onOpenSettings,
      onShow,
      onSubmit,
      results,
      searchHidden,
      searchValue,
      submitted,
      isSearchPage,
      unreadNotifications,
      showNotificationsBadge,
    } = this.props;
    const computedClass = classNames('drawer', `mbstobon-${elefriend}`);

    //  The result.
    return (
      <div className={computedClass} role='region' aria-label={intl.formatMessage(messages.compose)}>
        {multiColumn ? (
          <DrawerHeader
            columns={columns}
            unreadNotifications={unreadNotifications}
            showNotificationsBadge={showNotificationsBadge}
            intl={intl}
            onSettingsClick={onOpenSettings}
          />
        ) : null}
        {(multiColumn || isSearchPage) && <DrawerSearch
            intl={intl}
            onChange={onChange}
            onClear={onClear}
            onShow={onShow}
            onSubmit={onSubmit}
            submitted={submitted}
            value={searchValue}
          /> }
        <div className='drawer__pager'>
          {!isSearchPage && <div className='drawer__inner'>
            <DrawerAccount account={account} />
            <Composer />
            {multiColumn && (
              <div className='drawer__inner__mastodon'>
                {mascot ? <img alt='' draggable='false' src={mascot} /> : <button className='mastodon' onClick={onClickElefriend} />}
              </div>
            )}
          </div>}

          {(multiColumn || isSearchPage) &&
            <DrawerResults
              results={results}
              visible={submitted && !searchHidden}
            />}
        </div>
      </div>
    );
  }

}

//  Props.
Drawer.propTypes = {
  intl: PropTypes.object.isRequired,
  isSearchPage: PropTypes.bool,
  multiColumn: PropTypes.bool,

  //  State props.
  account: ImmutablePropTypes.map,
  columns: ImmutablePropTypes.list,
  results: ImmutablePropTypes.map,
  elefriend: PropTypes.number,
  searchHidden: PropTypes.bool,
  searchValue: PropTypes.string,
  submitted: PropTypes.bool,
  unreadNotifications: PropTypes.number,
  showNotificationsBadge: PropTypes.bool,

  //  Dispatch props.
  onChange: PropTypes.func,
  onClear: PropTypes.func,
  onClickElefriend: PropTypes.func,
  onShow: PropTypes.func,
  onSubmit: PropTypes.func,
  onOpenSettings: PropTypes.func,
};

//  Connecting and export.
export { Drawer as WrappedComponent };
export default wrap(Drawer, mapStateToProps, mapDispatchToProps, true);
