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

// More/Less views for edit pages
$(document).ready(function(){
        $("span#content_description_span").click(function(){
          $("div#content_description_form").toggle(); 
          var text=$("div#content_description_form").css("display");
          if (text == "none") {
             $(this).css("background-image","url('/images/facet_closed.png')");

          } else {
             $(this).css("background-image","url('/images/facet_open.png')");
          }
        });
}
);
$(document).ready(function(){
        $("span#contributors_span").click(function(){
          $("div#contributors_form").toggle(); 
          var text=$("div#contributors_form").css("display");
          if (text == "none") {
             $(this).css("background-image","url('/images/facet_closed.png')");

          } else {
             $(this).css("background-image","url('/images/facet_open.png')");
          }
        });
}
); 
$(document).ready(function(){
        $("span#rights_span").click(function(){
          $("div#rights_form").toggle(); 
          var text=$("div#rights_form").css("display");
          if (text == "none") {
             $(this).css("background-image","url('/images/facet_closed.png')");

          } else {
             $(this).css("background-image","url('/images/facet_open.png')");
          }
        });
}
); 

// When Editing metadata, use to set the language text to match the selected code. 
function setLanguageText()
{
 try{ 
   var lang_code_block=document.getElementById("language_lang_code");
   var lang_text=lang_code_block.options[lang_code_block.selectedIndex].text;
   var lang_text_block=document.getElementById("language_lang_text");
   lang_text_block.value=lang_text;}
 catch(err)
   { txt="The language metadata cannot be set due to a javascript fault.\nPlease contact the system administrator.";
     alert(txt);
     return false;
   }
}
