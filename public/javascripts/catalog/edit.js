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
      setUpInlineEdits();
      setUpStoryEditable();
      setUpDatePicker();
      setUpSliders();
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

    function setUpSliders () {
			$('fieldset.slider select').each(function(index) {
				$(this).selectToUISlider({labelSrc:'text'}).hide();
			});
			$('fieldset.slider:first .ui-slider ol:not(:first) .ui-slider-label').toggle();
    }
    
  	function setUpInlineEdits () {
  	  fluid.inlineEdits("#multipleEdit", {
          selectors : {
            text : ".editableText",
            editables : "li.editable"
          },
          componentDecorators: {
            type: "fluid.undoDecorator"
          },
          listeners : {
            onFinishEdit : myFinishEditListener,
            modelChanged : myModelChangedListener
          },
          defaultViewText: "click to edit"
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
          name      : "asset["+fieldName+"]["+index+"]",
          id        : "field_id",
          height    : "100",
          loadurl  : documentUrl + "?" + $.param(params)
        });
      });
    };

    function setUpDatePicker () {
      $('div.date-select', $el).each(function(index) {
        var $this = $(this);
        var opts = $.extend($this.data("opts"), {
          showWeeks:true,
          statusFormat:"l-cc-sp-d-sp-F-sp-Y",
          callbackFunctions:{
            "dateset": [saveDateWidgetEdit]
          }
        });
        datePickerController.createDatePicker(opts);
      });
    };

    // Inserting and removing simple inline edits
    function insertValue(element, event) {
      var fieldName = $(element).closest("dt").next("dd").attr("id");
      var values_list = $(element).closest("dt").next("dd").find("ol");
      var new_value_index = values_list.children('li').size();
      var unique_id = fieldName + "_" + new_value_index;

      var $item = $('<li class=\"editable\" name="asset[' + fieldName + '][' + new_value_index + ']"><a href="#" class="destructive"><img src="/images/delete.png" border="0" /></a><span class="flc-inlineEdit-text"></span></li>');
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
      var fieldName = $(element).closest("dt").next('dd').attr("id");
      var datastreamName = $(element).closest("dt").next('dd').attr("data-datastream-name");
      var values_list = $(element).closest("dt").next("dd").find("ol");
      var new_value_index = values_list.children('li').size();
      var unique_id =  "asset_" + fieldName + "_" + new_value_index;

      var $item = jQuery('<li class=\"field_value textile_value\" name="asset[' + fieldName + '][' + new_value_index + ']"><a href="#" class="destructive"><img src="/images/delete.png" border="0" /></a><div class="textile" id="'+fieldName+'_'+new_value_index+'">click to edit</div></li>');
      $item.appendTo(values_list);

      $("div.textile", $item).editable(documentUrl+"&format=textile", {
          method    : "PUT",
          indicator : "<img src='/images/ajax-loader.gif'>",
          loadtext  : "",
          type      : "textarea",
          submit    : "OK",
          cancel    : "Cancel",
          // tooltip   : "Click to edit #{field_name.gsub(/_/, ' ')}...",
          placeholder : "click to edit",
          onblur    : "ignore",
          name      : "asset["+fieldName+"]["+new_value_index+"]",
          id        : "field_id",
          height    : "100",
          loadurl  : documentUrl+"?datastream="+datastreamName+"&field="+fieldName+"&field_index="+new_value_index
      });

    };

    //Handlers for when you're done editing and want values to submit to the app.
    function myFinishEditListener(newValue, oldValue, editNode, viewNode) {
      // Only submit if the value has actually changed.
      if (newValue != oldValue) {
        var result = saveEdit($(viewNode).parent().attr("name"), newValue)
      }
      return result;
    };

    // Handler for ensuring that the undo decorator's actions will be submitted to the app.
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

    function saveDateWidgetEdit(callback) {
        // console.log(callback["id"], callback["dd"], callback["mm"], callback["yyyy"]);
        name = $("#"+callback["id"]).parent().attr("name");
        value = callback["yyyy"]+"-"+callback["mm"]+"-"+callback["dd"];
        // console.log(name);
        // console.log(value);
        saveEdit(name , value);
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

    // Remove the given value from its corresponding metadata field.
    // @param {Object} element - the element containing a value that should be removed.  element.name must be in format document[field_name][index]
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

$(function() {
    Hydrangea.FileUploader.setUp();
  });
