// Uncomment this if you want fluid to provide log messages in the console.
// see <http://wiki.fluidproject.org/display/fluid/Framework+Functions#FrameworkFunctions-fluid.log%28str%29>
// fluid.setLogging(true);

$(document).ready(function()
{
    //-------------------------------------------------------
    /*shows the loading div every time we have an Ajax call*/
    $("#loading").bind("ajaxSend", function(){
       $(this).show();
     }).bind("ajaxComplete", function(){
       $(this).hide();
   });
   //-------------------------------------------------------
})

jQuery(document).ready(function () {
    /* Example 3 - note the difference in the syntax */
    /* multiple inline edit requires each editable text object to be wrapped again inside another element */                
    var multiEdit = fluid.inlineEdits("#multipleEdit", {
        selectors : {
          text : ".editableText",
          editables : "dd.editable"
        }, 
        // componentDecorators: {
        //   type: "fluid.undoDecorator" 
        // },
        listeners : {
          onFinishEdit : myFinishEditListener
        }
    });
    // var singleEdit = fluid.inlineEdit("#foo", {});
    // singleEdit.edit();
});

function insertValue(fieldName) {
  var d = new Date(); // get milliseconds for unique identfier
  var unique_id = "document_" + fieldName + "_" + d.getTime();
  var div = jQuery('<dd id="'+unique_id+'" name="document[' + fieldName + '][-1]"><a href="javascript:void();" onClick="removeValue($(this).parent());" class="destructive"><img src="/images/delete.png" border="0" /></a><span class="flc-inlineEdit-text"></span></dd>');
  div.appendTo("#document_"+fieldName+"_new_values"); 
  //return false;
  var newVal = fluid.inlineEdit("#"+unique_id, {
    // componentDecorators: {
    //   type: "fluid.undoDecorator" 
    // },
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
  // Only submit if the value has actually changed.
  if (newValue != oldValue) {
    saveEdit($(viewNode).parent().attr("name"), newValue)
  }
  return true;
}

function saveEdit(field,value) {
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