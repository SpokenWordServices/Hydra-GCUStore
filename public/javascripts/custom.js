function async_load(url, divid) {
  $.ajax({
    type: "GET",
    url: url,
    dataType: "html",
    success: function(data){
            $(divid).html(data);
            $("#file_assets  .editable-container").hydraTextField();
            $("#file_assets  a.destroy_file_asset").hydraFileAssetDeleteButton();
          }
  });
  // $(divid).load(url);
  return null;
}

var Hydrangea = {};

Hydrangea.FileUploader = function() {
  var pid = null;

  return {
    setUp: function() {
      $("a#toggle-uploader").live('click', Hydrangea.FileUploader.toggle);
      pid = $("div#uploads").attr("data-pid");

    },
    toggle: function() {
      if ($("a#toggle-uploader").html().trim() === "Upload files") {
        $("a#toggle-uploader").html("Hide file uploader");
        async_load("/assets/" + pid + "/file_assets/new", "div#uploader");
      } else {
        $("a#toggle-uploader").html("Upload files");
        $("div#uploader").html("");
      }
      return false;
    }
  };
}();

// Accordion Behavior
jQuery(document).ready(function($) {

	// Replaced cumbersome jQuery UI Accordion with this much simpler version (Paul Wenzel)
	
    $('.accordion-section').children(":not(.section-title)").hide();
	
    $('.accordion-section .section-title').click(function(){
		if($(this).hasClass("active")) {
			
		} else {
			$(".active").siblings().hide()
			$(".active").toggleClass("active");
			$(this).siblings().toggle();
			$(this).addClass("active");
		}

     });

	$('.accordion-section .section-title:first').click();
	$('.accordion-section .section-title:first').addClass("active");


/*
	// activate accordion behavior for all accordion-section elements
	$(".accordion-section").accordion({
	    autoHeight: false,
	    clearStyle: false,
	    collapsible: true,
	    active: false,
	    icons: false
	}).bind("accordionchangestart",
	function(event, ui) {
		console.log('accordionchangestart triggered');
		$(".activeAccordion").removeClass("activeAccordion");
		
	}).bind("accordionchange",
	function(event, ui) {
		console.log('accordionchange triggered');
		// $(this).addClass("activeAccordion");
	});
	
    // open up the first accordion-section by "clicking"
    $(".accordion-section:first h2").click();
	$(".accordion-section:first").addClass("activeAccordion");
*/
    // Disable styles inherited by jQuery UI (see also bottom of public/plugin_assets/blacklight/stylesheets/jquery/ui-lightness/jquery-ui-1.8.1.custom.css)
	
    $(".ui-accordion-content").removeClass("ui-accordion ui-widget ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom ui-accordion-content-active");
    $(".accordion-section h2").removeClass("ui-accordion-header ui-helper-reset ui-state-active ui-corner-top ui-state-default ui-corner-all").css('cursor', 'pointer');
    $("div.ui-widget").css({
        "font": "inherit",
        "font-size": "inherit",
        'line-height': 'inherit'
    });

});
