import PropTypes from 'prop-types';
import React from 'react';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom';
import StatusContainer from '../../../containers/status_container';
import ComposeFormContainer from '../../compose/containers/compose_form_container';
import NotificationsContainer from '../../ui/containers/notifications_container';
import LoadingBarContainer from '../../ui/containers/loading_bar_container';
import ModalContainer from '../../ui/containers/modal_container';

const mapStateToProps = state => ({
  last: state.getIn(['compose', 'last']),
});

@connect(mapStateToProps)
class Content extends React.PureComponent {

  static propTypes = {
    last: PropTypes.string,
  }

  state = {
    initialLast: this.props.last,
  }

  render () {
    return this.props.last === this.state.initialLast ? (
      <ComposeFormContainer />
    ) : (
      <div className='compose-standalone__status'>
        <h1>
          <FormattedMessage
            id='compose_standalone.posted'
            defaultMessage='Success! You tooted:'
          />
        </h1>
        <StatusContainer id={this.props.last} standalone />
        <Link
          className='button compose-standalone__status__button'
          to='/getting-started'
        >
          <FormattedMessage
            id='compose_standalone.web'
            defaultMessage='Go to web'
          />
        </Link>
        <p className='compose-standalone__status__navigation'>
          <FormattedMessage
            id='compose_standalone.close'
            defaultMessage='Or, you can just close this window.'
          />
        </p>
      </div>
    );
  }

}

export default class Compose extends React.PureComponent {

  render () {
    return (
      <div>
        <Content />
        <NotificationsContainer />
        <ModalContainer />
        <LoadingBarContainer className='loading-bar' />
      </div>
    );
  }

}
