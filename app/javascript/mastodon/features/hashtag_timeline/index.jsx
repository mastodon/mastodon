import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { isEqual } from 'lodash';

import TagIcon from '@/material-icons/400-24px/tag.svg?react';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import { connectHashtagStream } from 'mastodon/actions/streaming';
import { fetchHashtag, followHashtag, unfollowHashtag } from 'mastodon/actions/tags';
import { expandHashtagTimeline, clearTimeline } from 'mastodon/actions/timelines';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';

import StatusListContainer from '../ui/containers/status_list_container';

import { HashtagHeader } from './components/hashtag_header';
import ColumnSettingsContainer from './containers/column_settings_container';

const mapStateToProps = (state, props) => ({
  hasUnread: state.getIn(['timelines', `hashtag:${props.params.id}${props.params.local ? ':local' : ''}`, 'unread']) > 0,
  tag: state.getIn(['tags', props.params.id]),
});

class HashtagTimeline extends PureComponent {

  disconnects = [];

  static contextTypes = {
    identity: PropTypes.object,
  };

  static propTypes = {
    params: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    hasUnread: PropTypes.bool,
    tag: ImmutablePropTypes.map,
    multiColumn: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('HASHTAG', { id: this.props.params.id }));
    }
  };

  title = () => {
    const { id } = this.props.params;
    const title  = [id];

    if (this.additionalFor('any')) {
      title.push(' ', <FormattedMessage key='any' id='hashtag.column_header.tag_mode.any'  values={{ additional: this.additionalFor('any') }} defaultMessage='or {additional}' />);
    }

    if (this.additionalFor('all')) {
      title.push(' ', <FormattedMessage key='all' id='hashtag.column_header.tag_mode.all'  values={{ additional: this.additionalFor('all') }} defaultMessage='and {additional}' />);
    }

    if (this.additionalFor('none')) {
      title.push(' ', <FormattedMessage key='none' id='hashtag.column_header.tag_mode.none' values={{ additional: this.additionalFor('none') }} defaultMessage='without {additional}' />);
    }

    return title;
  };

  additionalFor = (mode) => {
    const { tags } = this.props.params;

    if (tags && (tags[mode] || []).length > 0) {
      return tags[mode].map(tag => tag.value).join('/');
    } else {
      return '';
    }
  };

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  _subscribe (dispatch, id, tags = {}, local) {
    const { signedIn } = this.context.identity;

    if (!signedIn) {
      return;
    }

    let any  = (tags.any || []).map(tag => tag.value);
    let all  = (tags.all || []).map(tag => tag.value);
    let none = (tags.none || []).map(tag => tag.value);

    [id, ...any].map(tag => {
      this.disconnects.push(dispatch(connectHashtagStream(id, tag, local, status => {
        let tags = status.tags.map(tag => tag.name);

        return all.filter(tag => tags.includes(tag)).length === all.length &&
               none.filter(tag => tags.includes(tag)).length === 0;
      })));
    });
  }

  _unsubscribe () {
    this.disconnects.map(disconnect => disconnect());
    this.disconnects = [];
  }

  _unload () {
    const { dispatch } = this.props;
    const { id, local } = this.props.params;

    this._unsubscribe();
    dispatch(clearTimeline(`hashtag:${id}${local ? ':local' : ''}`));
  }

  _load() {
    const { dispatch } = this.props;
    const { id, tags, local } = this.props.params;

    this._subscribe(dispatch, id, tags, local);
    dispatch(expandHashtagTimeline(id, { tags, local }));
    dispatch(fetchHashtag(id));
  }

  componentDidMount () {
    this._load();
  }

  componentDidUpdate (prevProps) {
    const { params } = this.props;
    const { id, tags, local } = prevProps.params;

    if (id !== params.id || !isEqual(tags, params.tags) || !isEqual(local, params.local)) {
      this._unload();
      this._load();
    }
  }

  componentWillUnmount () {
    this._unsubscribe();
  }

  setRef = c => {
    this.column = c;
  };

  handleLoadMore = maxId => {
    const { dispatch, params } = this.props;
    const { id, tags, local }  = params;

    dispatch(expandHashtagTimeline(id, { maxId, tags, local }));
  };

  handleFollow = () => {
    const { dispatch, params, tag } = this.props;
    const { id } = params;
    const { signedIn } = this.context.identity;

    if (!signedIn) {
      return;
    }

    if (tag.get('following')) {
      dispatch(unfollowHashtag(id));
    } else {
      dispatch(followHashtag(id));
    }
  };

  render () {
    const { hasUnread, columnId, multiColumn, tag } = this.props;
    const { id, local } = this.props.params;
    const pinned = !!columnId;
    const { signedIn } = this.context.identity;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={`#${id}`}>
        <ColumnHeader
          icon='hashtag'
          iconComponent={TagIcon}
          active={hasUnread}
          title={this.title()}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
          showBackButton
        >
          {columnId && <ColumnSettingsContainer columnId={columnId} />}
        </ColumnHeader>

        <StatusListContainer
          prepend={pinned ? null : <HashtagHeader tag={tag} disabled={!signedIn} onClick={this.handleFollow} />}
          alwaysPrepend
          trackScroll={!pinned}
          scrollKey={`hashtag_timeline-${columnId}`}
          timelineId={`hashtag:${id}${local ? ':local' : ''}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.hashtag' defaultMessage='There is nothing in this hashtag yet.' />}
          bindToDocument={!multiColumn}
        />

        <Helmet>
          <title>#{id}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(HashtagTimeline);
