import PropTypes from 'prop-types';
import { Children, cloneElement } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { supportsPassiveEvents } from 'detect-passive-events';

import { scrollRight } from 'flavours/glitch/scroll';

import BundleContainer from '../containers/bundle_container';
import {
  Compose,
  Notifications,
  HomeTimeline,
  CommunityTimeline,
  PublicTimeline,
  HashtagTimeline,
  DirectTimeline,
  FavouritedStatuses,
  BookmarkedStatuses,
  ListTimeline,
  Directory,
} from '../util/async-components';

import BundleColumnError from './bundle_column_error';
import ColumnLoading from './column_loading';
import ComposePanel from './compose_panel';
import DrawerLoading from './drawer_loading';
import NavigationPanel from './navigation_panel';

const componentMap = {
  'COMPOSE': Compose,
  'HOME': HomeTimeline,
  'NOTIFICATIONS': Notifications,
  'PUBLIC': PublicTimeline,
  'REMOTE': PublicTimeline,
  'COMMUNITY': CommunityTimeline,
  'HASHTAG': HashtagTimeline,
  'DIRECT': DirectTimeline,
  'FAVOURITES': FavouritedStatuses,
  'BOOKMARKS': BookmarkedStatuses,
  'LIST': ListTimeline,
  'DIRECTORY': Directory,
};

export default class ColumnsArea extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
  };

  static propTypes = {
    columns: ImmutablePropTypes.list.isRequired,
    singleColumn: PropTypes.bool,
    children: PropTypes.node,
    openSettings: PropTypes.func,
  };

  // Corresponds to (max-width: $no-gap-breakpoint + 285px - 1px) in SCSS
  mediaQuery = 'matchMedia' in window && window.matchMedia('(max-width: 1174px)');

  state = {
    renderComposePanel: !(this.mediaQuery && this.mediaQuery.matches),
  };

  componentDidMount() {
    if (!this.props.singleColumn) {
      this.node.addEventListener('wheel', this.handleWheel, supportsPassiveEvents ? { passive: true } : false);
    }

    if (this.mediaQuery) {
      if (this.mediaQuery.addEventListener) {
        this.mediaQuery.addEventListener('change', this.handleLayoutChange);
      } else {
        this.mediaQuery.addListener(this.handleLayoutChange);
      }
      this.setState({ renderComposePanel: !this.mediaQuery.matches });
    }

    this.isRtlLayout = document.getElementsByTagName('body')[0].classList.contains('rtl');
  }

  componentWillUpdate(nextProps) {
    if (this.props.singleColumn !== nextProps.singleColumn && nextProps.singleColumn) {
      this.node.removeEventListener('wheel', this.handleWheel);
    }
  }

  componentDidUpdate(prevProps) {
    if (this.props.singleColumn !== prevProps.singleColumn && !this.props.singleColumn) {
      this.node.addEventListener('wheel', this.handleWheel, supportsPassiveEvents ? { passive: true } : false);
    }
  }

  componentWillUnmount () {
    if (!this.props.singleColumn) {
      this.node.removeEventListener('wheel', this.handleWheel);
    }

    if (this.mediaQuery) {
      if (this.mediaQuery.removeEventListener) {
        this.mediaQuery.removeEventListener('change', this.handleLayoutChange);
      } else {
        this.mediaQuery.removeListener(this.handleLayoutChange);
      }
    }
  }

  handleChildrenContentChange() {
    if (!this.props.singleColumn) {
      const modifier = this.isRtlLayout ? -1 : 1;
      this._interruptScrollAnimation = scrollRight(this.node, (this.node.scrollWidth - window.innerWidth) * modifier);
    }
  }

  handleLayoutChange = (e) => {
    this.setState({ renderComposePanel: !e.matches });
  };

  handleWheel = () => {
    if (typeof this._interruptScrollAnimation !== 'function') {
      return;
    }

    this._interruptScrollAnimation();
  };

  setRef = (node) => {
    this.node = node;
  };

  renderLoading = columnId => () => {
    return columnId === 'COMPOSE' ? <DrawerLoading /> : <ColumnLoading multiColumn />;
  };

  renderError = (props) => {
    return <BundleColumnError multiColumn errorType='network' {...props} />;
  };

  render () {
    const { columns, children, singleColumn, openSettings } = this.props;
    const { renderComposePanel } = this.state;

    if (singleColumn) {
      return (
        <div className='columns-area__panels'>
          <div className='columns-area__panels__pane columns-area__panels__pane--compositional'>
            <div className='columns-area__panels__pane__inner'>
              {renderComposePanel && <ComposePanel />}
            </div>
          </div>

          <div className='columns-area__panels__main'>
            <div className='tabs-bar__wrapper'><div id='tabs-bar__portal' /></div>
            <div className='columns-area columns-area--mobile'>{children}</div>
          </div>

          <div className='columns-area__panels__pane columns-area__panels__pane--start columns-area__panels__pane--navigational'>
            <div className='columns-area__panels__pane__inner'>
              <NavigationPanel onOpenSettings={openSettings} />
            </div>
          </div>
        </div>
      );
    }

    return (
      <div className='columns-area' ref={this.setRef}>
        {columns.map(column => {
          const params = column.get('params', null) === null ? null : column.get('params').toJS();
          const other  = params && params.other ? params.other : {};

          return (
            <BundleContainer key={column.get('uuid')} fetchComponent={componentMap[column.get('id')]} loading={this.renderLoading(column.get('id'))} error={this.renderError}>
              {SpecificComponent => <SpecificComponent columnId={column.get('uuid')} params={params} multiColumn {...other} />}
            </BundleContainer>
          );
        })}

        {Children.map(children, child => cloneElement(child, { multiColumn: true }))}
      </div>
    );
  }

}
