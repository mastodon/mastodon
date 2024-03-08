import { connect } from 'react-redux';

import { openModal } from 'flavours/glitch/actions/modal';

import ColumnsArea from '../components/columns_area';

const mapStateToProps = state => ({
  columns: state.getIn(['settings', 'columns']),
  isModalOpen: !!state.get('modal').modalType,
});

const mapDispatchToProps = dispatch => ({
  openSettings (e) {
    e.preventDefault();
    e.stopPropagation();
    dispatch(openModal({
      modalType: 'SETTINGS',
      modalProps: {},
    }));
  },
});

export default connect(mapStateToProps, mapDispatchToProps, null, { forwardRef: true })(ColumnsArea);
