import React from 'react';
import ComposeFormContainer from './containers/compose_form_container';
import NavigationContainer from './containers/navigation_container';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { mountCompose, unmountCompose } from 'flavours/glitch/actions/compose';
import { injectIntl, defineMessages } from 'react-intl';
import classNames from 'classnames';
import SearchContainer from './containers/search_container';
import Motion from 'flavours/glitch/util/optional_motion';
import spring from 'react-motion/lib/spring';
import SearchResultsContainer from './containers/search_results_container';
import { me, mascot } from 'flavours/glitch/util/initial_state';
import { cycleElefriendCompose } from 'flavours/glitch/actions/compose';
import HeaderContainer from './containers/header_container';

const messages = defineMessages({
  compose: { id: 'navigation_bar.compose', defaultMessage: 'Compose new post' },
});

const mapStateToProps = (state, ownProps) => ({
  elefriend: state.getIn(['compose', 'elefriend']),
  showSearch: ownProps.multiColumn ? state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']) : ownProps.isSearchPage,
});

const mapDispatchToProps = (dispatch, { intl }) => ({
  onClickElefriend () {
    dispatch(cycleElefriendCompose());
  },

  onMount () {
    dispatch(mountCompose());
  },

  onUnmount () {
    dispatch(unmountCompose());
  },
});

export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class Compose extends React.PureComponent {
  static propTypes = {
    multiColumn: PropTypes.bool,
    showSearch: PropTypes.bool,
    isSearchPage: PropTypes.bool,
    elefriend: PropTypes.number,
    onClickElefriend: PropTypes.func,
    onMount: PropTypes.func,
    onUnmount: PropTypes.func,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount () {
    const { isSearchPage } = this.props;

    if (!isSearchPage) {
      this.props.onMount();
    }
  }

  componentWillUnmount () {
    const { isSearchPage } = this.props;

    if (!isSearchPage) {
      this.props.onUnmount();
    }
  }

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

    return (
      <div className={computedClass} role='region' aria-label={intl.formatMessage(messages.compose)}>
        {multiColumn && <HeaderContainer />}

        {(multiColumn || isSearchPage) && <SearchContainer />}

        <div className='drawer__pager'>
          {!isSearchPage && <div className='drawer__inner'>
            <NavigationContainer />

            <ComposeFormContainer />

            <div className='drawer__inner__mastodon'>
              {mascot ? <img alt='' draggable='false' src={mascot} /> : <button className='mastodon' onClick={onClickElefriend} />}
            </div>
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
