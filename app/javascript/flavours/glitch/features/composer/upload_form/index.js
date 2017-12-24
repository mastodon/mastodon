//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  Components.
import ComposerUploadFormItem from './item';
import ComposerUploadFormProgress from './progress';

//  The component.
export default function ComposerUploadForm ({
  active,
  intl,
  media,
  onChangeDescription,
  onRemove,
  progress,
}) {
  const computedClass = classNames('composer--upload_form', { uploading: active });

  //  We need `media` in order to be able to render.
  if (!media) {
    return null;
  }

  //  The result.
  return (
    <div className={computedClass}>
      {active ? <ComposerUploadFormProgress progress={progress} /> : null}
      {media.map(item => (
        <ComposerUploadFormItem
          description={item.get('description')}
          key={item.get('id')}
          id={item.get('id')}
          intl={intl}
          preview={item.get('preview_url')}
          onChangeDescription={onChangeDescription}
          onRemove={onRemove}
        />
      ))}
    </div>
  );
}

//  Props.
ComposerUploadForm.propTypes = {
  active: PropTypes.bool,
  intl: PropTypes.object.isRequired,
  media: ImmutablePropTypes.list,
  onChangeDescription: PropTypes.func,
  onRemove: PropTypes.func,
  progress: PropTypes.number,
};
