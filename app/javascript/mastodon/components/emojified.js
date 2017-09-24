import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import React from 'react';

export default class Emojified extends ImmutablePureComponent {

  static propTypes = {
    tokens: ImmutablePropTypes.list.isRequired,
  };

  handleCustomEmojiClick = (e) => {
    if (this.context.router) {
      e.preventDefault();
      this.context.router.history.push(e.target.href);
    }
  }

  render () {
    const { tokens, ...props } = this.props;

    const elements = tokens.map((token, index) => {
      switch (token.get('type')) {
      case 'customEmoji':
        return (
          <a
            key={index} // the list is not expected to be reordered.
            href={`/emojis/${token.getIn(['src', 'id'])}`}
            onClick={this.handleCustomEmojiClick}
          >
           <img
            draggable='false'
            className="emojione"
            alt={token.get('alt')}
            title={token.get('title')}
            src={token.getIn(['src', 'url'])}
           />
          </a>
        );

      case 'emoji':
        return (
          <img
            draggable='false'
            className='emojione'
            key={index} // the list is not expected to be reordered.
            alt={token.get('alt')}
            title={token.get('title')}
            src={token.get('src')}
          />
        );

      case 'html':
        return (
          <span
            key={index} // the list is not expected to be reordered.
            dangerouslySetInnerHTML={{ __html: token.get('value') }}
          />
        );
      }
    });

    return (<span {...props}>{elements}</span>);
  }
}
