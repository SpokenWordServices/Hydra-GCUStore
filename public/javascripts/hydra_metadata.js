/**
 * Triggered when saving the selection from a drop-down menu.
 * @param {Object} element - the element whose value should be saved.  element.name must be in format document[field_name][index]
 */
function saveSelect(element) {
  if (element.value != '') { 
    saveEdit(element.name, element.value);
  }
}

function saveDateWidgetEdit(callback) {
    // console.log(callback["id"], callback["dd"], callback["mm"], callback["yyyy"]);
    name = $("#"+callback["id"]).parent().attr("name");
    value = callback["yyyy"]+"-"+callback["mm"]+"-"+callback["dd"];
    // console.log(name);
    // console.log(value);
    saveEdit(name , value);
}

/**
 * Remove the given value from its corresponding metadata field.
 * @param {Object} element - the element containing a value that should be removed.  element.name must be in format document[field_name][index]
 */
function removeFieldValue(element) {
  // alert("removing " + $(element).parent().attr("name"));
  saveEdit($(element).parent().attr("name"), "");
  $(element).parent().remove();
}


function insertTextileValue(fieldName, datastreamName, basicUrl) {
  var values_list = jQuery("#salt_document_"+fieldName+"_values");
  var new_value_index = values_list.children('li').size()
  var unique_id = "salt_document_" + fieldName + "_" + new_value_index;

  var div = jQuery('<li class=\"field_value textile_value\" id="'+unique_id+'" name="salt_document[' + fieldName + '][' + new_value_index + ']"><a href="javascript:void();" onClick="removeFieldValue(this);" class="destructive"><img src="/images/delete.png" border="0" /></a><div class="textile" id="'+fieldName+'_'+new_value_index+'">click to edit</div></li>');
  div.appendTo(values_list);
  $("#"+unique_id).children("#"+fieldName+"_"+new_value_index).editable(basicUrl+".textile", { 
      method    : "PUT", 
      indicator : "<img src='/images/ajax-loader.gif'>",
      loadtext  : "",
      type      : "textarea",
      submit    : "OK",
      cancel    : "Cancel",
      // tooltip   : "Click to edit #{field_name.gsub(/_/, ' ')}...",
      placeholder : "click to edit",
      onblur    : "ignore",
      name      : "salt_document["+fieldName+"]["+new_value_index+"]", 
      id        : "field_id",
      height    : "100",
      loadurl  : basicUrl+"?datastream="+datastreamName+"&field="+fieldName+"&field_index="+new_value_index
  });
}

/**
 * Create date picker widgets for an array of elements.
 * @param {Object} pickers array of date inputs
 */
var initAllDatePickers = function (pickers) {
  pickers.each(function (idx, picker) {
      initDatePicker(picker);
  });
};

/**
 * Inits a date picker for the given element.
 * @param {Object} editors array of rich inline editors.
 */
function initDatePicker(element) {
  var element_with_opts = {};
  element_with_opts[$(element).attr("id")] = "m-ds-d-ds-Y";
  var opts = {     
          formElements:element_with_opts, 
          callbackFunctions:{"dateset":[finishAssociatedInlineEdit]}                               
  };        
  datePickerController.createDatePicker(opts);
}

/**
 * Callback that returns the associated inlineEdit to its active state and updates its associated 'inactive' node's value
 * @param {Object} follows the signature of callbacks used by Unobrusive Date Picker v5
 * { 
 * "id": [the ID of the first form element stipulated within the initialisation object], 
 * "date": [a Javascript Date Object representing the selected date or NULL if no date is selected],
 * "dd": [the date part of the selected date or NULL if no date is selected], 
 * "mm": [the month part of the selected date or NULL if no date is selected], 
 * "yyyy": [the year part of the selected date or NULL if no date is selected],
 * // NOTE: only the "redraw" callback gets the following additional parameters
 * "firstDateDisplayed": [a String representing the YYYYMMDD value of the first date shown], 
 * "lastDateDisplayed": [a String representing the YYYYMMDD value of the last date shown] 
 * }
 */
function updateAssociatedInlineEdit(args) {
  var editableText = $("#"+args.id).parent().siblings(".flc-inlineEdit-text");
  editableText.text(datePickerController.printFormattedDate(args.date, "m-sl-d-sl-Y") + " ");
  editableText.click();
}

/**
 * Callback that returns the associated inlineEdit to its active state and updates its associated 'inactive' node's value
 * @param {Object} follows the signature of callbacks used by Unobrusive Date Picker v5
 * { 
 * "id": [the ID of the first form element stipulated within the initialisation object], 
 * "date": [a Javascript Date Object representing the selected date or NULL if no date is selected],
 * "dd": [the date part of the selected date or NULL if no date is selected], 
 * "mm": [the month part of the selected date or NULL if no date is selected], 
 * "yyyy": [the year part of the selected date or NULL if no date is selected],
 * // NOTE: only the "redraw" callback gets the following additional parameters
 * "firstDateDisplayed": [a String representing the YYYYMMDD value of the first date shown], 
 * "lastDateDisplayed": [a String representing the YYYYMMDD value of the last date shown] 
 * }
 */
function finishAssociatedInlineEdit(args) {
  var editableText = $("#"+args.id).parent().siblings(".flc-inlineEdit-text");
  editableText.click();
  editableText.parent().click();
}


jQuery(document).ready(function () 
{
  var datePickers = initAllDatePickers($(".date_picker"));
})