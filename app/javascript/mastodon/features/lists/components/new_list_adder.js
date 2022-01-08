import React from "react";

import CreateNewListForm from "./create_new_list_form";

const NewListAdder = React.forwardRef((props, ref) => {
  return (
    <div className="modal-root__modal list-editor">
      <CreateNewListForm listId={props.listId}/>
    </div>
  );
});

export default NewListAdder;
