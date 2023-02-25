//  Inspired by <CommonLink> from Mastodon GO!
//  ~ 😘 kibi!

//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';

//  Utils.
import { assignHandlers } from 'flavours/glitch/utils/react_helpers';

//  Handlers.
const handlers = {

  //  We don't handle clicks that are made with modifiers, since these
  //  often have special browser meanings (eg, "open in new tab").
  click (e) {
    const { onClick } = this.props;
    if (!onClick || e.button || e.ctrlKey || e.shiftKey || e.altKey || e.metaKey) {
      return;
    }
    onClick(e);
    e.preventDefault();  //  Prevents following of the link
  },
};

//  The component.
export default class Link extends React.PureComponent {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
  }

  //  Rendering.
  render () {
    const { click } = this.handlers;
    const {
      children,
      className,
      href,
      onClick,
      role,
      title,
      ...rest
    } = this.props;
    const computedClass = classNames('link', className, `role-${role}`);

    //  We assume that our `onClick` is a routing function and give it
    //  the qualities of a link even if no `href` is provided. However,
    //  if we have neither an `onClick` or an `href`, our link is
    //  purely presentational.
    const conditionalProps = {};
    if (href) {
      conditionalProps.href = href;
      conditionalProps.onClick = click;
    } else if (onClick) {
      conditionalProps.onClick = click;
      conditionalProps.role = 'link';
      conditionalProps.tabIndex = 0;
    } else {
      conditionalProps.role = 'presentation';
    }

    //  If we were provided a `role` it overwrites any that we may have
    //  set above.  This can be used for "links" which are actually
    //  buttons.
    if (role) {
      conditionalProps.role = role;
    }

    //  Rendering.  We set `rel='noopener'` for user privacy, and our
    //  `target` as `'_blank'`.
    return (
      <a
        className={computedClass}
        {...conditionalProps}
        rel='noopener'
        target='_blank'
        title={title}
        {...rest}
      >{children}</a>
    );
  }

}

//  Props.
Link.propTypes = {
  children: PropTypes.node,
  className: PropTypes.string,
  href: PropTypes.string,  //  The link destination
  onClick: PropTypes.func,  //  A function to call instead of opening the link
  role: PropTypes.string,  //  An ARIA role for the link
  title: PropTypes.string,  //  A title for the link
};
