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
      setUpTextileEditables();
      // setUpStoryEditable();
      setUpDatePicker();
      setUpSliders();
      setUpNewPermissionsForm();
      setUpNewContributorForm();
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

    //
    // Permissions
    // Use Ajax to add individual permissions entry to the page
    //
    // wait for the DOM to be loaded 
    function setUpNewPermissionsForm () {
        var options = { 
            clearForm: true,        // clear all form fields after successful submit 
            timeout:   2000,
            success:   insertPersonPermission  // post-submit callback 
        };
        // bind 'new_permissions'
        $('#new_permissions').ajaxForm(options); 
    };

    // post-submit callback 
    function insertPersonPermission(responseText, statusText, xhr, $form)  { 
      $("#individual_permissions").append(responseText);
      $('fieldset.slider select').last().selectToUISlider({labelSrc:'text'}).hide();
      $('fieldset.slider:first .ui-slider ol:not(:first) .ui-slider-label').toggle();
    };
    
    function removePermission(element) {
      
    }
    
    function updatePermission(element) {
      $.ajax({
         type: "PUT",
         url: element.closest("form").attr("action"),
         data: element.fieldSerialize(),
         success: function(msg){
     			$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in miliseconds
             stayTime:               6000,                   // time in miliseconds before the item has to disappear
             text:                   "Permissions for "+element.attr("id")+" have been set to "+element.fieldValue(),
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
      // Must submit to permissions controller.  (can't submit as regular metadata update to assets controller update method)
      // because we need to trigger the RightsMetadata update_permissions methods.
    }
    
    function setUpSliders () {
      sliderOpts = {
		    change: function(event, ui) { 
          var associatedSelect = $(ui.handle).parent().prev()
          updatePermission(associatedSelect);
        }
		  }
			$('fieldset.slider select').each(function(index) {
				$(this).selectToUISlider({
				  labelSrc:'text',
				  sliderOptions: sliderOpts
				}).hide();
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
  	
    // 
    // Contributors
    // 
    //
    // Use Ajax to add a contributor to the page
    //
    function setUpNewContributorForm () {
      $("#re-run-add-contributor-action").click(function() {
        addContributor("person");
      });
      $("#add_person").click(function() {
        addContributor("person");
      });
      $("#add_organization").click(function() {
        addContributor("organization");
      });
      $("#add_conference").click(function() {
        addContributor("conference");
      });
    }
    
    function addContributor(type) {
      var content_type = $("form#new_contributor > input#content_type").first().attr("value");
      var insertion_point_selector = "#"+type+"_entries";
      var url = $("form#new_contributor").attr("action");
      
      $.post(url, {contributor_type: type, content_type: content_type},function(data) {
        $(insertion_point_selector).append(data);
        console.log(data);
        fluid.inlineEdits("#"+$(data).attr("id"), {
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
        
      });

    };
    
  	

  	function setUpTextileEditables() {
      $('.textile', $el).each(function(index) {
        var $textileContainer = $(this).closest("dd")
        // var $textileContainer = $(this);     
        var datastreamName = $textileContainer.attr('data-datastream-name');
        var fieldName = $textileContainer.attr("id");

        var submitUrl = appendFormat(documentUrl, {format: "textile"});

        var $textiles = $("ol div.textile", $textileContainer);
        $textiles.each(function(index) {
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
            name      : "asset["+datastreamName+"]["+fieldName+"]["+index+"]",
            id        : "field_id",
            height    : "100",
            loadurl  : documentUrl + "?" + $.param(params)
          });
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
      var $containerDD = $(element).closest("dt").next('dd');
      var fieldName = $containerDD.attr("id");
      var values_list = $containerDD.find("ol");
      var datastreamName = $containerDD.attr('data-datastream-name');
      
      var new_value_index = values_list.children('li').size();
      var unique_id = fieldName + "_" + new_value_index;

      var $item = $('<li class=\"editable\" name="asset['+datastreamName+'[' + fieldName + '][' + new_value_index + ']"><a href="#" class="destructive"><img src="/images/delete.png" border="0" /></a><span class="flc-inlineEdit-text"></span></li>');
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
    
    
    /*
    * Simplified function based on jQuery AppendFormat plugin by Edgar J. Suarez
    * http://github.com/edgarjs/jquery-append-format
    */
    function appendFormat(url,options) {
       var qs = '';
       var baseURL;
       
       if(url.indexOf("?") !== -1) {
           baseURL = url.substr(0, url.indexOf("?"));
           qs = url.substr(url.indexOf("?"), url.length);
       } else {
           baseURL = url;
      }
      if((/\/.*\.\w+$/).exec(baseURL) && !options.force) {
          return baseURL + qs;
      } else {
          return baseURL + '.' + options.format + qs;
      }
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
