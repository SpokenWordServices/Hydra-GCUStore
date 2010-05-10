(function($) {

  var CatalogEdit = function(options, $element) {
  	
    // PRIVATE VARIABLES
  
    var $el = $element,
        opts = options,
        $metaDataForm;
  
    // constructor
  	function init() {
      $metaDataForm = $("form#document_metadata", $el);
      $metaDataForm.delegate("a.addval", "click", function(e) {
        insertValue(this, e);
        e.preventDefault();
      });
      $metaDataForm.delegate("a.destructive", "click", function(e) {
        removeFieldValue(this, e);
        e.preventDefault();
      });
  	};
  	
    // PRIVATE METHODS
    
    /***
     * Inserting and removing simple inline edits
     */
    function insertValue(element, event) {
      var fieldName = $(element).attr("data-fieldName");
      var values_list = $(element).closest("dt").next("dd");
      var new_value_index = values_list.children('li').size()
      var unique_id = "document_" + fieldName + "_" + new_value_index;
      
      var div = $('<li class=\"editable\" id="'+unique_id+'" name="document[' + fieldName + '][' + new_value_index + ']"><a href="#" class="destructive"><img src="/images/delete.png" border="0" /></a><span class="flc-inlineEdit-text"></span></li>');
      div.appendTo(values_list); 
      var newVal = fluid.inlineEdit("#"+unique_id, {
        componentDecorators: {
          type: "fluid.undoDecorator" 
        },
        listeners : {
          onFinishEdit : myFinishEditListener,
          modelChanged : myModelChangedListener
        }
      });
      newVal.edit();
    };
    
    /***
     * Handlers for when you're done editing and want values to submit to the app. 
     */
    
    function myFinishEditListener(newValue, oldValue, editNode, viewNode) {
      // Only submit if the value has actually changed.
      if (newValue != oldValue) {
        var result = saveEdit($(viewNode).parent().attr("name"), newValue)
      }
      return result;
    };
        
    /***
     * Handler for ensuring that the undo decorator's actions will be submitted to the app.
     */
    function myModelChangedListener(model, oldModel, source) {
      // this was a really hacky way of checking if the model is being changed by the undo decorator
      if (source && source.options.selectors.undoControl) {  
        var result = saveEdit(source.component.editContainer.parent().attr("name"), model.value);
        return result;
      }
    };
    
  function saveEdit(field,value) {
    $.ajax({
      type: "PUT",
      url: $el.attr("action"),
      dataType : "json",
      data: field+"="+value,
      success: function(msg){
  			$.noticeAdd({
          inEffect:               {opacity: 'show'},      // in effect
          inEffectDuration:       600,                    // in effect duration in miliseconds
          stayTime:               6000,                   // time in miliseconds before the item has to disappear
          text:                   "Your edit to "+ msg.updated[0].field_name +" has been saved as "+msg.updated[0].value+" at index "+msg.updated[0].index,   // content of the item
          stay:                   false,                  // should the notice item stay or not?
          type:                   'notice'                // could also be error, succes				
         });
      },
      error: function(xhr, textStatus, errorThrown){
  			$.noticeAdd({
          inEffect:               {opacity: 'show'},      // in effect
          inEffectDuration:       600,                    // in effect duration in miliseconds
          stayTime:               6000,                   // time in miliseconds before the item has to disappear
          text:                   'Your changes to' + field + ' could not be saved because of '+ xhr.statusText + ': '+ xhr.responseText,   // content of the item
          stay:                   true,                  // should the notice item stay or not?
          type:                   'error'                // could also be error, succes				
         });
      }
    });
  };
  
  /**
   * Remove the given value from its corresponding metadata field.
   * @param {Object} element - the element containing a value that should be removed.  element.name must be in format document[field_name][index]
   */
  function removeFieldValue(element, event) {
    saveEdit($(element).parent().attr("name"), "");
    $(element).parent().remove();
  };

    // PUBLIC METHODS
    
    // run constructor;
    init();
  };
  
  // jQuery plugin method
  $.fn.catalogEdit = function(options) {
    return this.each(function() {
      var $this = $(this);
      
      // If not already stored, store plugin object in this element's data
      if (!$this.data('catalogEdit')) {
        $this.data('dashboardIndex', new CatalogEdit(options, $this));
      }
    });
  };
     
})(jQuery);