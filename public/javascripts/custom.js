function async_load(url, divid) {
  $(divid).load(url);
  return null;
}

// function async_load_prototype(url, divid) {
//  new Ajax.Request(url,
//    {
//      method:'get',
//      onSuccess: function(transport){
//      $(divid).update(transport.responseText);
//          alert("Success! \n\n" + response);
//      },
//      onFailure: function(){ alert('Something went wrong loading ' + url) }
//    });
// }
