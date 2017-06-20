import React from 'react';
import PropTypes from 'prop-types';
import Switch from 'react-router-dom/Switch';
import Route from 'react-router-dom/Route';

import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';
import Bundle from '../components/bundle';

// Small wrapper to pass multiColumn to the route components
export const WrappedSwitch = ({ multiColumn, children }) => (
  <Switch>
    {React.Children.map(children, child => React.cloneElement(child, { multiColumn }))}
  </Switch>
);

WrappedSwitch.propTypes = {
  multiColumn: PropTypes.bool,
  children: PropTypes.node,
};

// Small Wraper to extract the params from the route and pass
// them to the rendered component, together with the content to
// be rendered inside (the children)
export class WrappedRoute extends React.Component {

  static propTypes = {
    component: PropTypes.func.isRequired,
    content: PropTypes.node,
    multiColumn: PropTypes.bool,
  }

  renderComponent = ({ match }) => {
    this.match = match; // Needed for this.renderBundle

    const { component } = this.props;

    return (
      <Bundle load={component}>{this.renderBundle}</Bundle>
    );
  }

  renderBundle = (Component) => {
    const { match: { params }, props: { content, multiColumn } } = this;

    return Component ? <Component params={params} multiColumn={multiColumn}>{content}</Component> : (
      <Column>
        <ColumnHeader icon=' ' title='' multiColumn={false} />
        <div className='scrollable' />
      </Column>
    );
  }

  render () {
    const { component: Component, content, ...rest } = this.props;

    return <Route {...rest} render={this.renderComponent} />;
  }

}
