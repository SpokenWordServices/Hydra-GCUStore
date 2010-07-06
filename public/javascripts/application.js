// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
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
  });
});

function createAssetNavigateTo(elem, link) {
  $('#re-run-action')
  .attr('value', $(elem).text())
  .click(function() {
    $('#create-asset-menu').hide();
    location.href = link;
  });

  location.href = link;
}

$(function() {
  $("#re-run-add-contributor-action").next().button( {
    text: false,
    icons: { primary: "ui-icon-triangle-1-s" }
  })
  .click(function() {
    $('#add-contributor-menu').is(":hidden") ? 
      $('#add-contributor-menu').show() : $('#add-contributor-menu').hide();
    })
  .parent().buttonset();
  
  $('#add-contributor-menu').mouseleave(function(){
    $('#add-contributor-menu').hide();
  });
});