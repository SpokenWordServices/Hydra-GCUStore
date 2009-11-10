function async_load(url, divid) {
	new Ajax.Request(url,
	  {
	    method:'get',
	    onSuccess: function(transport){
			$(divid).update(transport.responseText);
	      	alert("Success! \n\n" + response);
	    },
	    onFailure: function(){ alert('Something went wrong loading ' + url) }
	  });
}
