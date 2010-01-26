// Uncomment this if you want fluid to provide log messages in the console.
// see <http://wiki.fluidproject.org/display/fluid/Framework+Functions#FrameworkFunctions-fluid.log%28str%29>
fluid.setLogging(true);

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
    var singleValueEdits = fluid.inlineEdits("#multipleEdit", {
        selectors : {
          text : ".editableText",
          editables : "li.editable"
        }, 
        // componentDecorators: {
        //   type: "fluid.undoDecorator" 
        // },
        listeners : {
          onFinishEdit : myFinishEditListener
        }
    });
    

    var richEdits = setupRichTextEdits($(".editable_textarea"), {
        // FCKEditor: {BasePath: "/plugin_assets/fluid-infusion/javascripts/../infusion/tests/manual-tests/lib/fckeditor/"},
        FCKEditor: {
          BasePath: "/javascripts/fckeditor/", 
          ToolbarSet: "Basic"
        },
        // componentDecorators: {
        //     type: "fluid.undoDecorator"
        // },
        listeners : {
          onFinishEdit : myFinishEditListener
        },
        defaultViewText: "click to edit"
    });
});

/**
 * Creates a whole list of Rich Text Editors editors.
 */
var setupRichTextEdits = function (editables, options) {
    var editors = [];
    editables.each(function (idx, editable) {
        editors.push(fluid.inlineEdit.FCKEditor($(editable), options));
    });
    makeAllButtons(editors);
    return editors;
};


/**
 * Create cancel and save buttons for a rich inline editor.
 * @param {Object} editor 
 */
var makeButtons = function (editor) {
    $(".save", editor.container).click(function(event){
        event.preventDefault();
        editor.finish();
        return false;
    });

    $(".cancel", editor.container).click(function(event){
        event.preventDefault();
        editor.cancel();
        return false;
    });
};

/**
 * Create cancel and save buttons for all rich text editors.
 * @param {Object} editors array of rich inline editors.
 */
var makeAllButtons = function (editors) {
    while (editors.length > 0) {
        makeButtons(editors.pop());
    }
};

/***
 * Inserting and removing simple inline edits
 */
 
function insertValue(fieldName) {
  var d = new Date(); // get milliseconds for unique identfier
  var unique_id = "document_" + fieldName + "_" + d.getTime();
  var div = jQuery('<li class=\"editable\" id="'+unique_id+'" name="document[' + fieldName + '][-1]"><a href="javascript:void();" onClick="removeValue($(this).parent());" class="destructive"><img src="/images/delete.png" border="0" /></a><span class="flc-inlineEdit-text"></span></li>');
  div.appendTo("#document_"+fieldName+"_values"); 
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

/***
 * Inserting and removing rich inline edits
 */
 
 function insertTextAreaValue(fieldName) {
   var d = new Date(); // get milliseconds for unique identfier
   var unique_id = "document_" + fieldName + "_" + d.getTime();
   // <div class="flc-inlineEdit-text">&nbsp;
   // </div>
   // <div class="flc-inlineEdit-editContainer">
   //     <textarea></textarea>
   //     <button class="save">Save</button> <button class="cancel">Cancel</button>
   // </div>
   var div = jQuery('<li class=\"editable_textarea\" id="'+unique_id+'" name="document[' + fieldName + '][-1]"><a href="javascript:void();" onClick="removeValue($(this).parent());" class="destructive"><img src="/images/delete.png" border="0" /></a><div class="flc-inlineEdit-text"></div><div class="flc-inlineEdit-editContainer"><textarea></textarea><button class="save">Save</button> <button class="cancel">Cancel</button></div> </dd>');
   div.appendTo("#document_"+fieldName+"_values"); 
   //return false;

   var newVal = fluid.inlineEdit.FCKEditor("#"+unique_id, {
       // FCKEditor: {BasePath: "/plugin_assets/fluid-infusion/javascripts/../infusion/tests/manual-tests/lib/fckeditor/"},
        FCKEditor: {
          BasePath: "/javascripts/fckeditor/", 
          ToolbarSet: "Basic"
        },
        // componentDecorators: {
        //     type: "fluid.undoDecorator"
        // },
        listeners : {
          onFinishEdit : myFinishEditListener
        },
        defaultViewText: "click to edit"
    })
    makeButtons(newVal)
    newVal.edit();

 }


/***
 * Handlers for when you're done editing and want values to submit to the app. 
 */

function myFinishEditListener(newValue, oldValue, editNode, viewNode) {
  // Only submit if the value has actually changed.
  if (newValue != oldValue) {
    var result = saveEdit($(viewNode).parent().attr("name"), newValue)
  }
  return result;
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
    },
    error: function(xhr, textStatus, errorThrown){
			jQuery.noticeAdd({
        inEffect:               {opacity: 'show'},      // in effect
        inEffectDuration:       600,                    // in effect duration in miliseconds
        stayTime:               6000,                   // time in miliseconds before the item has to disappear
        text:                   'Your changes to' + field + ' could not be saved because of '+ xhr.statusText + ': '+ xhr.responseText,   // content of the item
        stay:                   true,                  // should the notice item stay or not?
        type:                   'error'                // could also be error, succes				
       });
    }
  });
}