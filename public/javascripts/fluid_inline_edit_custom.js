jQuery(document).ready(function () {
    /* Example 3 - note the difference in the syntax */
    /* multiple inline edit requires each editable text object to be wrapped again inside another element */                
    var multiEdit = fluid.inlineEdits("#multipleEdit", {
        selectors : {
          text : ".editableText",
          editables : "dd"
        }, 
        componentDecorators: {
          type: "fluid.undoDecorator" 
        }
    });
});
