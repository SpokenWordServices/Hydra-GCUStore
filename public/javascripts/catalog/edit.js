(function($) {

  var CatalogEdit = function(options, $element) {
  	
    // PRIVATE VARIABLES
  
    var $el = $element,
        opts = options;
  
    // constructor
  	function init() {
  	
  	};
  	
    // PRIVATE METHODS


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