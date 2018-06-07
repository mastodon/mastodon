import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { expandPublicTimeline } from '../../actions/timelines';
import { addColumn, removeColumn, moveColumn, changeColumnParams } from '../../actions/columns';
import ColumnSettingsContainer from './containers/column_settings_container';
import SectionHeadline from '../community_timeline/components/section_headline';
import { connectPublicStream } from '../../actions/streaming';
import classNames from 'classnames';

const messages = defineMessages({
  title: { id: 'column.public', defaultMessage: 'Federated timeline' },
  showTabs: { id: 'column_header.show_tabs', defaultMessage: 'Show tabs' },
  hideTabs: { id: 'column_header.hide_tabs', defaultMessage: 'Hide tabs' },
});

const mapStateToProps = (state, { onlyMedia }) => ({
  hasUnread: state.getIn(['timelines', `public${onlyMedia ? ':media' : ''}`, 'unread']) > 0,
});

@connect(mapStateToProps)
@injectIntl
export default class PublicTimeline extends React.PureComponent {

  static defaultProps = {
    onlyMedia: false,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
    hasUnread: PropTypes.bool,
    onlyMedia: PropTypes.bool,
  };

  state = {
    showTabs: false,
  };

  handlePin = () => {
    const { columnId, dispatch, onlyMedia } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('PUBLIC', { other: { onlyMedia } }));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  componentDidMount () {
    const { dispatch, onlyMedia } = this.props;

    dispatch(expandPublicTimeline({ onlyMedia }));
    this.disconnect = dispatch(connectPublicStream({ onlyMedia }));
  }

  componentDidUpdate (prevProps) {
    if (prevProps.onlyMedia !== this.props.onlyMedia) {
      const { dispatch, onlyMedia } = this.props;

      this.disconnect();
      dispatch(expandPublicTimeline({ onlyMedia }));
      this.disconnect = dispatch(connectPublicStream({ onlyMedia }));
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = maxId => {
    const { dispatch, onlyMedia } = this.props;

    dispatch(expandPublicTimeline({ maxId, onlyMedia }));
  }

  handleHeadlineLinkClick = e => {
    const { columnId, dispatch } = this.props;
    const onlyMedia = /\/media$/.test(e.currentTarget.href);

    dispatch(changeColumnParams(columnId, { other: { onlyMedia } }));
  }

  handleHeadlineToggle = () => {
    this.setState({ showTabs: !this.state.showTabs });
  }

  render () {
    const { intl, columnId, hasUnread, multiColumn, onlyMedia } = this.props;
    const { showTabs } = this.state;
    const pinned = !!columnId;

    const headline = showTabs && (
      <SectionHeadline
        timelineId='public'
        to='/timelines/public'
        pinned={pinned}
        onlyMedia={onlyMedia}
        onClick={this.handleHeadlineLinkClick}
      />
    );

    const toggleHeadlineButton = (
      <button
        onClick={this.handleHeadlineToggle}
        className={classNames('column-header__button', { active: showTabs })}
        title={intl.formatMessage(showTabs ? messages.hideTabs : messages.showTabs)}
        aria-label={intl.formatMessage(showTabs ? messages.hideTabs : messages.showTabs)}
        aria-pressed={showTabs ? 'true' : 'false'}
      >
        <i className='fa fa-toggle-on' />
      </button>
    );

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='globe'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          extraButton={toggleHeadlineButton}
          multiColumn={multiColumn}
        >
          <ColumnSettingsContainer />
        </ColumnHeader>

        <StatusListContainer
          prepend={headline}
          alwaysPrepend
          timelineId={`public${onlyMedia ? ':media' : ''}`}
          onLoadMore={this.handleLoadMore}
          trackScroll={!pinned}
          scrollKey={`public_timeline-${columnId}`}
          emptyMessage={<FormattedMessage id='empty_column.public' defaultMessage='There is nothing here! Write something publicly, or manually follow users from other instances to fill it up' />}
        />
      </Column>
    );
  }

}
