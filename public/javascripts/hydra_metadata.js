/**
 * Triggered when saving the selection from a drop-down menu.
 * @param {Object} element - the element whose value should be saved.  element.name must be in format document[field_name][index]
 */
function saveSelect(element) {
  if (element.value != '') { 
    saveEdit(element.name, element.value);
  }
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
  //var datePickers = initAllDatePickers($(".date_picker"));
})