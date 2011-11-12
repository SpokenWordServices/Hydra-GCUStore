JavaScript Document
$(document).ready(function(){
	$(".slide_button").click(function(){
		$("#slide_panel").slideToggle("slow");
		$(this).toggleClass("minus_icon"); return false;
	});
});
