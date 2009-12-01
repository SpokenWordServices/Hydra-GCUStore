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
    var singleEdit = fluid.inlineEdit("#foo", {});
    singleEdit.edit();
});

function insertValue(fieldName) {
  var div = jQuery('<dd id="document_' + fieldName + '_-1" name="document[' + fieldName + '][-1]"><a href="javascript:void();" onClick="removeValue($(this).parent());" class="destructive"><img src="/images/delete.png" border="0" /></a><span class="flc-inlineEdit-text"></span></dd>');
  div.appendTo("#document_"+fieldName+"_new_values"); 
  //return false;
  var newVal = fluid.inlineEdit("#document_" + fieldName + "_-1", {
    componentDecorators: {
      type: "fluid.undoDecorator" 
    },
    listeners : {
      onFinishEdit : myFinishEditListener
    }
  });
  newVal.edit();
}

function removeValue(node) {
  node.remove();
}

function myFinishEditListener(newValue, oldValue, editNode, viewNode) {
  saveEdit($(viewNode).parent().attr("name"), newValue)
  return true;
}

function saveEdit(field,value) {
  //alert("Attempting to save "+value+" as the new value for "+field+" by submitting to "+rel)
  $.ajax({
    type: "PUT",
    url: $("form#document_metadata").attr("action"),
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