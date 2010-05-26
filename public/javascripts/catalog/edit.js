(function($) {

  var CatalogEdit = function(options, $element) {
  	
    // PRIVATE VARIABLES
  
    var $el = $element,
        opts = options,
        $metaDataForm,
        documentUrl,
        resourceType;
        
    // PRIVATE METHODS
  
    // constructor
  	function init() {
  	  $metaDataForm = $("form#document_metadata", $el);
      documentUrl = $metaDataForm.attr("action");
      resourceType = $metaDataForm.attr('data-resourceType');
      bindDomEvents();
      setUpStoryEditable();
  	};
  	
  	function bindDomEvents () {
  	  $metaDataForm.delegate("a.addval.input", "click", function(e) {
        insertValue(this, e);
        e.preventDefault();
      });
      $metaDataForm.delegate("a.addval.textArea", "click", function(e) {
        insertTextileValue(this, e);
        e.preventDefault();
      });
      $metaDataForm.delegate("a.destructive", "click", function(e) {
        removeFieldValue(this, e);
        e.preventDefault();
      });
      
      $metaDataForm.delegate('select.metadata-dd', 'change', function(e) {
        saveSelect(this);
      });
  	};
  	
  	function setUpStoryEditable() {
      var $storyDD = $("dd#story", $el);
      var datastreamName = $storyDD.attr('data-datastream-name');
      var fieldName = $storyDD.attr("id");
      var submitUrl = documentUrl + ".textile";
      var $stories = $("ol div.textile", $storyDD);
      $stories.each(function(index) {
        var params = {
          datastream: datastreamName,
          field: fieldName,
          field_index: index
        }
        
        $(this).editable(submitUrl, {
          method    : "PUT", 
          indicator : "<img src='/images/ajax-loader.gif'>",
          type      : "textarea",
          submit    : "OK",
          cancel    : "Cancel",
          tooltip   : "Click to edit " + fieldName.replace(/_/, ' ') + "...",
          placeholder : "click to edit",
          onblur    : "ignore",
          name      : resourceType+"["+fieldName+"]["+index+"]", 
          id        : "field_id",
          height    : "100",
          loadurl  : documentUrl + "?" + $.param(params)
        });
      });
    };
    
    /***
     * Inserting and removing simple inline edits
     */
    function insertValue(element, event) {
      var fieldName = $(element).closest("dt").next("dd").attr("id");
      var values_list = $(element).closest("dt").next("dd").find("ol");
      var new_value_index = values_list.children('li').size();
      var unique_id = fieldName + "_" + new_value_index;
      
      var $item = $('<li class=\"editable\" name="'+resourceType+'[' + fieldName + '][' + new_value_index + ']"><a href="#" class="destructive"><img src="/images/delete.png" border="0" /></a><span class="flc-inlineEdit-text"></span></li>');
      $item.appendTo(values_list); 
      var newVal = fluid.inlineEdit($item, {
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

    function insertTextileValue(element, event) {
      var basicUrl = $(element).attr("href");
      var fieldName = $(element).closest("dt").next('dd').attr("id");
      var datastreamName = $(element).closest("dt").next('dd').attr("data-datastream-name");
      var values_list = $(element).closest("dt").next("dd").find("ol");
      var new_value_index = values_list.children('li').size();
      var unique_id = resourceType + "_" + fieldName + "_" + new_value_index;

      var $item = jQuery('<li class=\"field_value textile_value\" name="'+resourceType+'[' + fieldName + '][' + new_value_index + ']"><a href="#" class="destructive"><img src="/images/delete.png" border="0" /></a><div class="textile" id="'+fieldName+'_'+new_value_index+'">click to edit</div></li>');
      $item.appendTo(values_list);
      
      $("div.textile", $item).editable(basicUrl+".textile", { 
          method    : "PUT", 
          indicator : "<img src='/images/ajax-loader.gif'>",
          loadtext  : "",
          type      : "textarea",
          submit    : "OK",
          cancel    : "Cancel",
          // tooltip   : "Click to edit #{field_name.gsub(/_/, ' ')}...",
          placeholder : "click to edit",
          onblur    : "ignore",
          name      : resourceType+"["+fieldName+"]["+new_value_index+"]", 
          id        : "field_id",
          height    : "100",
          loadurl  : basicUrl+"?datastream="+datastreamName+"&field="+fieldName+"&field_index="+new_value_index
      });
      
    };
    
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
   var div = jQuery('<li class=\"editable_textarea\" id="'+unique_id+'" name="document[' + fieldName + '][-1]"><a href="javascript:void();" onClick="removeFieldValue(this);" class="destructive"><img src="/images/delete.png" border="0" /></a><div class="flc-inlineEdit-text"></div><div class="flc-inlineEdit-editContainer"><textarea></textarea><button class="save">Save</button> <button class="cancel">Cancel</button></div> </dd>');
   div.appendTo("#document_"+fieldName+"_values"); 
   //return false;
  
   var newVal = fluid.inlineEdit.FCKEditor("#"+unique_id, {
       // FCKEditor: {BasePath: "/plugin_assets/fluid-infusion/javascripts/../infusion/tests/manual-tests/lib/fckeditor/"},
        FCKEditor: {
          BasePath: "/javascripts/fckeditor/", 
          ToolbarSet: "Basic"
        },
        componentDecorators: {
          type: "fluid.undoDecorator" 
        },
        listeners : {
          onFinishEdit : myFinishEditListener,
          modelChanged : myModelChangedListener
        },
        defaultViewText: "click to edit"
    })
    makeButtons(newVal)
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
    
  function saveSelect(element) {
    if (element.value != '') { 
      saveEdit(element.name, element.value);
    }
  };
    
  function saveEdit(field,value) {
    $.ajax({
      type: "PUT",
      url: $("form#document_metadata").attr("action"),
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
  function removeFieldValue(element) {
    saveEdit($(element).parent().attr("name"), "");
    $(element).parent().remove();
  }

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