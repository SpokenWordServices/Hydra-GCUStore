// The following was breaking the facets
/*
$(document).ready(function() {
 $('#facets ul').each(function(){
   var ul = $(this);
   // find all ul's that don't have any span descendants with a class of "selected"
   if($('span.selected', ul).length == 0){
        // hide it
        ul.hide();
        // attach the toggle behavior to the h3 tag
        $('h3', ul.parent()).click(function(){
           // toggle the next ul sibling
           $(this).next('ul').slideToggle();
 	   $(this).toggleClass("facet_selected");	   
       });
   }
  
   
});

});
*/

/* GBS Cover Script by Tim Spalding/LibraryThing */
function addTheCover(booksInfo) 
  {
	for (i in booksInfo) 
	{ 
	  var book = booksInfo[i]; 
	  if (book.thumbnail_url != undefined) 
	  {  
		document.getElementById('gbsthumbnail').innerHTML = '<img src="' + book.thumbnail_url + '"/>';  
	  }
	}	
  }


// JavaScript Document
$(document).ready(function(){
        $("span#additional_resources_span").click(function(){
          $("div#resources").slideToggle("fast"); 
          var text = $(this).text();
          if (text == "Show additional information") {
            $(this).text("Hide additional information");
            $(this).css("background-image","url('/images/facet_open.png')");
          } else {
            $(this).text("Show additional information");
            $(this).css("background-image","url('/images/facet_closed.png')");
          }
        });
}
);

// More/Less view for metadata

$(document).ready(function(){
        $("span#additional_description_span").click(function(){
          $("div#description_note").toggle(); 
          var text = $(this).text();
          if (text == "More") {
            $(this).text("Less");
            $(this).css("background-image","url('/images/facet_open.png')");
          } else {
            $(this).text("More");
            $(this).css("background-image","url('/images/facet_closed.png')");
          }
        });
}
);
