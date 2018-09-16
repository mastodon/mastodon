import { connect } from 'react-redux';
import TemplatePickerDropdown from '../components/template_picker_dropdown';

const mapStateToProps = state => ({
  custom_templates: state.get('custom_templates'),
});

const mapDispatchToProps = (dispatch, { onPickTemplate }) => ({
  onPickTemplate: template => {
    onPickTemplate(template.get('content'));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(TemplatePickerDropdown);
