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
  alert("removing " + $(element).parent().attr("name"));
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
 * Create cancel and save buttons for all rich text editors.
 * @param {Object} editors array of rich inline editors.
 */
function initDatePicker(element) {
  var element_with_opts = {};
  element_with_opts[$(element).attr("id")] = "d-sl-m-sl-Y";
  var opts = {     
          formElements:element_with_opts 
  };        
  datePickerController.createDatePicker(opts);
}

jQuery(document).ready(function () 
{
  var datePickers = initAllDatePickers($(".date_picker"));
})