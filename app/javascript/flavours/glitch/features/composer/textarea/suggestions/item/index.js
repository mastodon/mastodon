//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';

//  Components.
import AccountContainer from 'flavours/glitch/containers/account_container';

//  Utils.
import { unicodeMapping } from 'flavours/glitch/util/emoji';
import { assignHandlers } from 'flavours/glitch/util/react_helpers';

//  Gets our asset host from the environment, if available.
const assetHost = process.env.CDN_HOST || '';

//  Handlers.
const handlers = {

  //  Handles a click on a suggestion.
  handleClick (e) {
    const {
      index,
      onClick,
    } = this.props;
    if (onClick) {
      e.preventDefault();
      e.stopPropagation();  //  Prevents following account links
      onClick(index);
    }
  },

  //  This prevents the focus from changing, which would mess with
  //  our suggestion code.
  handleMouseDown (e) {
    e.preventDefault();
  },
};

//  The component.
export default class ComposerTextareaSuggestionsItem extends React.Component {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
  }

  //  Rendering.
  render () {
    const {
      handleMouseDown,
      handleClick,
    } = this.handlers;
    const {
      selected,
      suggestion,
    } = this.props;
    const computedClass = classNames('composer--textarea--suggestions--item', { selected });

    //  If the suggestion is an object, then we render an emoji.
    //  Otherwise, we render a hashtag if it starts with #, or an account.
    let inner;
    if (typeof suggestion === 'object') {
      let url;
      if (suggestion.custom) {
        url = suggestion.imageUrl;
      } else {
        const mapping = unicodeMapping[suggestion.native] || unicodeMapping[suggestion.native.replace(/\uFE0F$/, '')];
        if (mapping) {
          url = `${assetHost}/emoji/${mapping.filename}.svg`;
        }
      }
      if (url) {
        inner = (
          <div className='emoji'>
            <img
              alt={suggestion.native || suggestion.colons}
              className='emojione'
              src={url}
            />
            {suggestion.colons}
          </div>
        );
      }
    } else if (suggestion[0] === '#') {
      inner = suggestion;
    } else {
      inner = (
        <AccountContainer
          id={suggestion}
          small
        />
      );
    }

    //  The result.
    return (
      <div
        className={computedClass}
        onMouseDown={handleMouseDown}
        onClickCapture={handleClick}  //  Jumps in front of contents
        role='button'
        tabIndex='0'
      >
        { inner }
      </div>
    );
  }

}

//  Props.
ComposerTextareaSuggestionsItem.propTypes = {
  index: PropTypes.number,
  onClick: PropTypes.func,
  selected: PropTypes.bool,
  suggestion: PropTypes.oneOfType([PropTypes.object, PropTypes.string]),
};
