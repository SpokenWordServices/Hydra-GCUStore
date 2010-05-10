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
  	};
  	
    // PRIVATE METHODS
    
    function insertValue(element, event) {
      var fieldName = $(element).attr("data-fieldName");
      var values_list = $(element).closest("dt").next("dd");
      var new_value_index = values_list.children('li').size()
      var unique_id = "document_" + fieldName + "_" + new_value_index;
      
      var div = $('<li class=\"editable\" id="'+unique_id+'" name="document[' + fieldName + '][' + new_value_index + ']"><a href="javascript:void();" onClick="removeFieldValue(this);" class="destructive"><img src="/images/delete.png" border="0" /></a><span class="flc-inlineEdit-text"></span></li>');
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