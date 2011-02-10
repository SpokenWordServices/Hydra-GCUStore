 // Facets
$(document).ready(function() {
 $('#facets ul').each(function(){
   var ul = $(this);
   // find all ul's that don't have any span descendants with a class of "selected"
   if($('span.selected', ul).length == 0  ){
        // hide it
        if (ul.prev('h3').attr("class") != "facet_selected"){
          ul.hide();
        }
        // attach the toggle behavior to the h3 tag
        $('h3', ul.parent()).click(function(){
           $(this).toggleClass("facet_selected");
           $(this).next('ul').slideToggle();
       });
   }else{
     ul.prev('h3').attr("class","facet_selected");
   }
 });
});
