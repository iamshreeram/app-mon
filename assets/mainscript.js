/* mainscript.js is for updating page based on date manupulation */

function getFileName(d) {
      return d.replace(/[^0-9 ]/g, "");
    }
function handler(e){
      var dat = e.target.value;
      var CURRENTDATE = new Date().toJSON().slice(0,10).replace(/-/g,'-');
      if (dat == CURRENTDATE ) {
        filename = "today.html";
      } else {
        filename = getFileName(dat)+".html";
      }
      // Getting the iframe
      var iframeTag= window.frames[0];
      // Getting its source url
      var x =  iframeTag.location.href;
      // Making some operations to build the new url
      var pos = x.lastIndexOf('/');
      x=x.substring(0, pos);
      var url = window.location.href; //This is the url of the whole page
     //filename = 'http://google.com';
     //filename = filename+"&output=embed";
     // Putting the new url in the Iframe
      iframeTag.location.href=filename;
}