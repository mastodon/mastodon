import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ConversationContainer from '../containers/conversation_container';
import ScrollableList from '../../../components/scrollable_list';
import { debounce } from 'lodash';

export default class ConversationsList extends ImmutablePureComponent {

  static propTypes = {
    conversations: ImmutablePropTypes.list.isRequired,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
    onLoadMore: PropTypes.func,
    shouldUpdateScroll: PropTypes.func,
  };

  getCurrentIndex = id => this.props.conversations.findIndex(x => x.get('id') === id)

  handleMoveUp = id => {
    const elementIndex = this.getCurrentIndex(id) - 1;
    this._selectChild(elementIndex);
  }

  handleMoveDown = id => {
    const elementIndex = this.getCurrentIndex(id) + 1;
    this._selectChild(elementIndex);
  }

  _selectChild (index) {
    const element = this.node.node.querySelector(`article:nth-of-type(${index + 1}) .focusable`);

    if (element) {
      element.focus();
    }
  }

  setRef = c => {
    this.node = c;
  }

  handleLoadOlder = debounce(() => {
    const last = this.props.conversations.last();

    if (last && last.get('last_status')) {
      this.props.onLoadMore(last.get('last_status'));
    }
  }, 300, { leading: true })

  render () {
    const { conversations, onLoadMore, ...other } = this.props;

    return (
      <ScrollableList {...other} onLoadMore={onLoadMore && this.handleLoadOlder} scrollKey='direct' ref={this.setRef}>
        {conversations.map(item => (
          <ConversationContainer
            key={item.get('id')}
            conversationId={item.get('id')}
            onMoveUp={this.handleMoveUp}
            onMoveDown={this.handleMoveDown}
          />
        ))}
      </ScrollableList>
    );
  }

}
