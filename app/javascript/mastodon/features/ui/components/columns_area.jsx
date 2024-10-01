import PropTypes from 'prop-types';
import { Children, cloneElement, useCallback } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { scrollRight } from '../../../scroll';
import BundleContainer from '../containers/bundle_container';
import {
  Compose,
  NotificationsWrapper,
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
import { useColumnsContext } from '../util/columns_context';

import BundleColumnError from './bundle_column_error';
import { ColumnLoading } from './column_loading';
import ComposePanel from './compose_panel';
import DrawerLoading from './drawer_loading';
import NavigationPanel from './navigation_panel';

const componentMap = {
  'COMPOSE': Compose,
  'HOME': HomeTimeline,
  'NOTIFICATIONS': NotificationsWrapper,
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

const TabsBarPortal = () => {
  const {setTabsBarElement} = useColumnsContext();

  const setRef = useCallback((element) => {
    if(element)
      setTabsBarElement(element);
  }, [setTabsBarElement]);

  return <div id='tabs-bar__portal' ref={setRef} />;
};

export default class ColumnsArea extends ImmutablePureComponent {
  static propTypes = {
    columns: ImmutablePropTypes.list.isRequired,
    isModalOpen: PropTypes.bool.isRequired,
    singleColumn: PropTypes.bool,
    children: PropTypes.node,
  };

  // Corresponds to (max-width: $no-gap-breakpoint - 1px) in SCSS
  mediaQuery = 'matchMedia' in window && window.matchMedia('(max-width: 1174px)');

  state = {
    renderComposePanel: !(this.mediaQuery && this.mediaQuery.matches),
  };

  componentDidMount() {
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

  componentWillUnmount () {
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
      scrollRight(this.node, (this.node.scrollWidth - window.innerWidth) * modifier);
    }
  }

  handleLayoutChange = (e) => {
    this.setState({ renderComposePanel: !e.matches });
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
    const { columns, children, singleColumn, isModalOpen } = this.props;
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
            <div className='tabs-bar__wrapper'><TabsBarPortal /></div>
            <div className='columns-area columns-area--mobile'>{children}</div>
          </div>

          <div className='columns-area__panels__pane columns-area__panels__pane--start columns-area__panels__pane--navigational'>
            <div className='columns-area__panels__pane__inner'>
              <NavigationPanel />
            </div>
          </div>
        </div>
      );
    }

    return (
      <div className={`columns-area ${ isModalOpen ? 'unscrollable' : '' }`} ref={this.setRef}>
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
