import { connect } from 'react-redux';
import ColumnsArea from '../components/columns_area';

const mapStateToProps = state => ({
  columns: state.getIn(['settings', 'columns']),
});

export default connect(mapStateToProps, null, null, { withRef: true })(ColumnsArea);
