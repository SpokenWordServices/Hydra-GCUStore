function async_load(url, divid) {
  $(divid).load(url);
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

    // activate accordion behavior for all accordion-section elements
    $(".accordion-section").accordion({
        autoHeight: false,
        clearStyle: false,
        collapsible: true,
        active: false,
        icons: false
    });

    // open up the first accordion-section by "clicking"
    $(".accordion-section:first h2").click();

    // Disable styles inherited by jQuery UI (see also bottom of public/plugin_assets/blacklight/stylesheets/jquery/ui-lightness/jquery-ui-1.8.1.custom.css)
    $(".ui-accordion-content").removeClass("ui-accordion ui-widget ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom ui-accordion-content-active");
    $(".accordion-section h2").removeClass("ui-accordion-header ui-helper-reset ui-state-active ui-corner-top ui-state-default ui-corner-all").css('cursor', 'pointer');
    $("div.ui-widget").css({
        "font": "inherit",
        "font-size": "inherit",
        'line-height': 'inherit'
    });

});
