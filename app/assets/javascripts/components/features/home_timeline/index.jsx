import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import { refreshTimeline } from '../../actions/timelines';
import { injectIntl } from 'react-intl';

const HomeTimeline = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(refreshTimeline('home'));
  },

  render () {
    const { intl } = this.props;

    return (
      <Column icon='home' heading={intl.formatMessage({ id: 'column.home', defaultMessage: 'Home' })}>
        <StatusListContainer {...this.props} type='home' />
      </Column>
    );
  },

});

export default connect()(injectIntl(HomeTimeline));
