(function($) {
 
  
   $.fn.hydraMetadata = {

     insertTextField: function() {},
     insertTextileField: function() {},
     removeFieldValue: function() {},
     setUpNewContributorForm: function() {},
     addContributor: function() {},
     removeContributor: function() {},
     
     saveSelect: function() {},
     saveDateWidgetEdit: function() {},
     
     fluidFinishEditListener: function() {},
     fluidModelChangedListener: function() {},
     saveEdit: function() {},
     
     // Submit a destroy request
     deleteFileAsset: function(el, url) {
       var $el = $(el);
       var $fileAssetNode = $el.closest(".file_asset");
       $.ajax({
         type: "DELETE",
         url: url,
         beforeSend: function() {
   				$fileAssetNode.animate({'backgroundColor':'#fb6c6c'},300);
   			},
   			success: function() {
   				$fileAssetNode.slideUp(300,function() {
   					$fileAssetNode.remove();
   				});
 				}
       });
     },
     
     /*
     * Simplified function based on jQuery AppendFormat plugin by Edgar J. Suarez
     * http://github.com/edgarjs/jquery-append-format
     */
     appendFormat: function(url,options) {
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
     
   };
   
   $.fn.hydraTextField = function(settings) {
     var config = {'foo': 'bar'};
 
     if (settings) $.extend(config, settings);
 
     this.each(function() {
       // element-specific code here
     });
 
     return this;
 
   };
   
   $.fn.hydraTextileField = function(settings) {
     var config = {'foo': 'bar'};
 
     if (settings) $.extend(config, settings);
 
     this.each(function() {
       // element-specific code here
     });
 
     return this;
 
   };
   
   $.fn.hydraDatePicker = function(settings) {
     var config = {'foo': 'bar'};
 
     if (settings) $.extend(config, settings);
 
     this.each(function() {
       // element-specific code here
     });
 
     return this;
 
   };
   $.fn.hydraSlider = function(settings) {
     var config = {'foo': 'bar'};
 
     if (settings) $.extend(config, settings);
 
     this.each(function() {
       // element-specific code here
     });
 
     return this;
 
   };
   
   $.fn.hydraNewPermissionsForm = function(settings) {
     var config = {'foo': 'bar'};
 
     if (settings) $.extend(config, settings);
 
     this.each(function() {
       // element-specific code here
     });
 
     return this;
 
   };
   
   $.fn.hydraNewContributorForm = function(settings) {
     var config = {'foo': 'bar'};
 
     if (settings) $.extend(config, settings);
 
     this.each(function() {
       // element-specific code here
     });
 
     return this;
 
   };
   
 })(jQuery);