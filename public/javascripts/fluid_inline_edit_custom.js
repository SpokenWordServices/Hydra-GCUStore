jQuery(document).ready(function () {
    /* Example 3 - note the difference in the syntax */
    /* multiple inline edit requires each editable text object to be wrapped again inside another element */                
    var multiEdit = fluid.inlineEdits("#multipleEdit", {
        selectors : {
          text : ".editableText",
          editables : "dd"
        }, 
        componentDecorators: {
          type: "fluid.undoDecorator" 
        },
        listeners : {
          onFinishEdit : myFinishEditListener
        }
    });
});

function myFinishEditListener(newValue, oldValue, editNode, viewNode) {
  //alert(this+"You edited the field "+$(viewNode).attr('rel')+", replacing \""+oldValue+"\" with \""+newValue+"\"")
  saveEdit(viewNode.id, newValue, $(viewNode).attr('rel'))
  return true;
}

function saveEdit(field,value,rel) {
  //alert("Attempting to save "+value+" as the new value for "+field+" by submitting to "+rel)
  $.ajax({
    type: "PUT",
    url: rel,
    dataType : "json",
    data: field+"="+value,
    success: function(msg){
			jQuery.noticeAdd({
        inEffect:               {opacity: 'show'},      // in effect
        inEffectDuration:       600,                    // in effect duration in miliseconds
        stayTime:               6000,                   // time in miliseconds before the item has to disappear
        text:                   'Your edit has been saved',   // content of the item
        stay:                   false,                  // should the notice item stay or not?
        type:                   'notice'                // could also be error, succes				
       });
    }
  });
}