// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  var elemFirst = $('ul#create-asset-menu li:first-child');	
  setupNavigation(elemFirst, elemFirst.text());
	
  $("#re-run-action").next().button( {
    text: false,
    icons: { primary: "ui-icon-triangle-1-s" }
  })
  .click(function() {
    $('#create-asset-menu').is(":hidden") ? 
      $('#create-asset-menu').show() : $('#create-asset-menu').hide();
    })
  .parent().buttonset();
  
  $('#create-asset-menu').mouseleave(function(){
    $('#create-asset-menu').hide();
  })
  .css('top', $('re-run-action').height());
});

function setupNavigation(elem, link) {
  $('#re-run-action')
  .attr('value', $(elem).text())
  .click(function() {
    $('#create-asset-menu').hide();
    location.href = link;
  });
}

function navigateTo(elem, link) {
  setupNavigation(elem, link);	
  $('#re-run-action').click();	
}

