(:~ 
 : restxq interface for XMark benchmark
 :
 :)
module namespace sr = 'apb.xmark.rest';
declare default function namespace 'apb.xmark.rest'; 

(:~
 : abide application entry point.
 :)
declare 
%rest:GET %rest:path("xmark")
%output:method("html")   
function xmark() {
<div>dd</div>
};

declare 
%rest:POST %rest:path("xmark")
%output:method("html")   
function xmark-post() {
<div>run</div>
};
