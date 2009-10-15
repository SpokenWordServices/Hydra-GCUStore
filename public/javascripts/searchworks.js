 // Google Book Covers


function getGBSItem(iNum) {
  for (var i=0; i<standard_nums.length; i++) {
	if (standard_nums[i].match(iNum)) {
	  return standard_nums[i];
	}
  }
}


function printGBSCall() {
    var cCode = '';
    new_nums = new Array();
    for(var i = 0;i < standard_nums.length;i++){
      new_nums.push(standard_nums[i]);
      if( (i%15) == 0 ){
        cCode += "<script type='text/javascript' src='";
        cCode += "http://books.google.com/books?bibkeys=";
        cCode += new_nums.join();
        cCode += "&callback=processGBS&jscmd=viewapi'>";
        cCode += "</script>";
        new_nums = [];
      }
    }
    cCode += "<script type='text/javascript' src='";
    cCode += "http://books.google.com/books?bibkeys=";
    cCode += new_nums.join();
    cCode += "&callback=processGBS&jscmd=viewapi'>";
    cCode += "</script>";
    new_nums = [];
    document.write(cCode);
    return;
}
function processGBS(data) {
  for (iNum in data) {
    var bookInfo = data[iNum];
    var cover_id = getGBSItem(iNum).replace(/,/g,"");
    var imgEl = $("#" + cover_id.replace(/:/g,""));
    if (bookInfo.thumbnail_url != undefined && imgEl.attr('src') == "/images/spacer.png") {
      if(imgEl.attr("name") == 'large_cover'){
        var thumb_url = bookInfo.thumbnail_url.replace(/pg=\w+/, "printsec=frontcover");
        thumb_url = thumb_url.replace("zoom=5","zoom=1");

        //if(bookInfo.preview == 'partial'){
        //  $('#gbs_text').html('Preview at Google Books');
        //}else if (bookInfo.preview == 'full'){
        //  $('#gbs_text').html('Read it at Google Books');
        //}
        if($("#online_h2").css("display") == 'none'){
          $("#online_h2").toggle();
        }
        $('#preview_info').toggle();
        $('#gbs_preview2').attr('href',bookInfo.info_url);
        if(bookInfo.embeddable){
          //$('#preview_link').toggle();
          var embedd_code = unescape("%3Cscript type='text/javascript'%3EGBS_setLanguage('en');%3C/script%3E");
          embedd_code += unescape("%3Cscript type='text/javascript'%3E");
          //embedd_code += "GBS_insertPreviewButtonPopup('" + bookInfo.preview_url + "');";
          embedd_code += "GBS_insertPreviewButtonPopup('" + iNum + "');";
          embedd_code += unescape("%3C/script%3E");
          document.write(embedd_code);

          //$('#cover_container').before(embedd_code);
          //$('#cover_container').toggle();
          //$('#placeholder').attr('src',bookInfo.preview_url);
          //google.load("books", "0");
          //google.setOnLoadCallback(initialize);
        }
      }else{
        //var thumb_url = bookInfo.thumbnail_url;
        var thumb_url = bookInfo.thumbnail_url.replace(/pg=\w+/, "printsec=frontcover");
        thumb_url = thumb_url.replace("zoom=5","zoom=1");
      }
      imgEl.attr("src", "")
      imgEl.attr("src", thumb_url);
      imgEl.toggle();
      
    }
  }
}

$(document).ready(function() {
          var pop_up_img = $("#__GBS_Button0");
          pop_up_img.remove();
          $('#cover_container').append(pop_up_img);
 $('#facets ul, #advanced_search_facets ul').each(function(){
   var ul = $(this);
   // find all ul's that don't have any span descendants with a class of "selected"
   if($('span.selected', ul).length == 0 && ul.attr("id") != "related_subjects"  ){
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
 
 // Help Text
 $(".help_text_link").each(function(){
   $(this).click(function(){
     $("#" + $(this).attr("name")).toggle();
   });
 });
 
 // 856's
 $('#more_link').click(function(){
   $('#more_link').toggle();
   $('#less_link').toggle();
   $('li .more').each(function(){
     $(this).toggle();
   });
   return false;
 });
 $('#less_link').click(function(){
   $('#less_link').toggle();
   $('#more_link').toggle();
   $('li .more').each(function(){
      $(this).toggle();
    });
    return false;
 });
 
 // Online H2, needs reworking later
 if( $(".record_url").length > 0 || $("#gbs_preview2").attr("href") != "" || $("ul.online").length > 0){
   if($("#online_h2").css("display") == 'none'){
     $("#online_h2").toggle();
   }   
 }
 
 // Search button
 $('#spec_search').toggle();
 $('#hidden_qt').attr("name","qt");
 $('#hidden_qt').attr("id","qt");
 $('#search_button').click(function(){
   $('#search_links').toggle();
 });
 
 $('#spec_search a').each(function(){
   $(this).click(function(){
     if($(this).attr("id") != 'seach_button_link'){
       $('#qt').attr('value',$(this).attr("class"));
       $('#search_links').toggle();
       if($(this).text() == 'Everything'){
         $('#seach_button_link').text("SEARCH");
       }else{
         $('#seach_button_link').text("Search " + $(this).text());
       }
     }
     $('form:first').trigger("submit");
     return false;
   });
 });
 
 
 // Send To Button
 $('#send_to_div').toggle();
 $('#send_to_link').mouseover(function(){
   if($('#send_to_div').css("display") == 'none'){
     $('#send_to_div').toggle();
   }
 });
 $('#send_to_div').mouseleave(function(){
   $('#send_to_div').toggle();
 });
 $('#send_to_div a').each(function(){
   $(this).click(function(){
     if($('#send_to_div').css("display") == 'none') {
       $('#send_to_div').toggle();
     }
   });
 });
 $('#send_to_div br').each(function(){
   $(this).toggle();
 });
});