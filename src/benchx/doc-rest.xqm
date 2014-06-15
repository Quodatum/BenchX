(:~ 
 : A RESTXQ interface for documentation
 :@author Andy Bunce
 :@version 0.1
 :)
module namespace bm = 'apb.doc.rest';
declare default function namespace 'apb.doc.rest'; 

import module namespace doc = 'apb.doc' at 'lib.xq/doctools.xqm';


(:~
 : show xqdoc for rest api
 :)
declare 
%rest:GET %rest:path("{$app}/doc/server/xqdoc")
%output:method("html")  
function xqdoc($app as xs:string) 
{
    doc:generate-html(fn:resolve-uri("benchx-rest.xqm"))
};
 
(:~
 : show xqdoc for rest api
 :)
declare 
%rest:GET %rest:path("{$app}/doc/server/wadl")
%output:method("html")  
function wadl($app as xs:string) 
{
  doc:wadl("/" || $app) 
}; 

(:~
 : show components for rest api
 :)
declare 
%rest:GET %rest:path("{$app}/doc/client/components")
%output:method("html")  
function client-components($app as xs:string) 
{
  let $src:="../" || $app || "/components" 
  return fn:doc($src) 
}; 
