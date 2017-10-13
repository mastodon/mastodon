import { connect } from 'react-redux';
import DoodleButton from '../components/doodle_button';
import { openModal } from '../../../actions/modal';
import { uploadCompose } from '../../../actions/compose';

const mapStateToProps = state => ({
  disabled: state.getIn(['compose', 'is_uploading']) || (state.getIn(['compose', 'media_attachments']).size > 3 || state.getIn(['compose', 'media_attachments']).some(m => m.get('type') === 'video')),
});

//https://stackoverflow.com/questions/35940290/how-to-convert-base64-string-to-javascript-file-object-like-as-from-file-input-f
function dataURLtoFile(dataurl, filename) {
  let arr = dataurl.split(','), mime = arr[0].match(/:(.*?);/)[1],
    bstr = atob(arr[1]), n = bstr.length, u8arr = new Uint8Array(n);
  while(n--){
    u8arr[n] = bstr.charCodeAt(n);
  }
  return new File([u8arr], filename, { type: mime });
}

const mapDispatchToProps = dispatch => ({

  onOpenCanvas () {
    dispatch(openModal('DOODLE', {
      status,
      onDoodleSubmit: (b64data) => {
        dispatch(uploadCompose([dataURLtoFile(b64data, 'doodle.png')]));
      },
    }));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(DoodleButton);
