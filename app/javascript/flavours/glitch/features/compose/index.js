//  Package imports.
import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages } from 'react-intl';
import classNames from 'classnames';

//  Actions.
import { cycleElefriendCompose } from 'flavours/glitch/actions/compose';

//  Components.
import ComposeFormContainer from './containers/compose_form_container';
import HeaderContainer from './containers/header_container';
import SearchContainer from './containers/search_container';
import SearchResultsContainer from './containers/search_results_container';
import NavigationContainer from './containers/navigation_container';
import spring from 'react-motion/lib/spring';

//  Utils.
import { me, mascot } from 'flavours/glitch/util/initial_state';
import Motion from 'flavours/glitch/util/optional_motion';

//  Messages.
const messages = defineMessages({
  compose: { id: 'navigation_bar.compose', defaultMessage: 'Compose new toot' },
});

//  State mapping.
const mapStateToProps = (state, ownProps) => ({
  elefriend: state.getIn(['compose', 'elefriend']),
  showSearch: ownProps.multiColumn ? state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']) : ownProps.isSearchPage,
});

//  Dispatch mapping.
const mapDispatchToProps = (dispatch, { intl }) => ({
  onClickElefriend () {
    dispatch(cycleElefriendCompose());
  },
});

//  The component.
export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class Compose extends React.PureComponent {
  static propTypes = {
    intl: PropTypes.object.isRequired,
    isSearchPage: PropTypes.bool,
    multiColumn: PropTypes.bool,
    showSearch: PropTypes.bool,

    //  State props.
    elefriend: PropTypes.number,
    unreadNotifications: PropTypes.number,

    //  Dispatch props.
    onClickElefriend: PropTypes.func,
  };

  //  Rendering.
  render () {
    const {
      elefriend,
      intl,
      multiColumn,
      onClickElefriend,
      isSearchPage,
      showSearch,
    } = this.props;
    const computedClass = classNames('drawer', `mbstobon-${elefriend}`);

    //  The result.
    return (
      <div className={computedClass} role='region' aria-label={intl.formatMessage(messages.compose)}>
        {multiColumn && <HeaderContainer />}

        {(multiColumn || isSearchPage) && <SearchContainer />}

        <div className='drawer__pager'>
          {!isSearchPage && <div className='drawer__inner'>
            <NavigationContainer />
            <ComposeFormContainer />
            {multiColumn && (
              <div className='drawer__inner__mastodon'>
                {mascot ? <img alt='' draggable='false' src={mascot} /> : <button className='mastodon' onClick={onClickElefriend} />}
              </div>
            )}
          </div>}

          <Motion defaultStyle={{ x: isSearchPage ? 0 : -100 }} style={{ x: spring(showSearch || isSearchPage ? 0 : -100, { stiffness: 210, damping: 20 }) }}>
            {({ x }) => (
              <div className='drawer__inner darker' style={{ transform: `translateX(${x}%)`, visibility: x === -100 ? 'hidden' : 'visible' }}>
                <SearchResultsContainer />
              </div>
            )}
          </Motion>
        </div>
      </div>
    );
  }

}
