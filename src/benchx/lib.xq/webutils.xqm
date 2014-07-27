(:~ 
: web utils
: @author andy bunce
: @since oct 2012
:)

module namespace web = 'apb.web.utils3';
declare default function namespace 'apb.web.utils3'; 

declare namespace rest = 'http://exquery.org/ns/restxq';
import module namespace session ="http://basex.org/modules/session";


(:~
: execute function fn if session has loggedin user with matching role else 401
:)
declare function role-check($role as xs:string,$fn){
  let $uid:=session:get("uid")
  return if($uid) then
        $fn()
         else http-auth("Whizz apb auth",())
};

(:~ return user of raise error if none
: @TODO role check
:)
declare function user($role as xs:string){
  let $uid:=session:get("uid")
  return if($uid) then
        $uid
        else fn:error(xs:QName('web:session-user'),"not logged in") 
};

declare function status($code,$reason){
   <rest:response>            
       <http:response status="{$code}" reason="{$reason}"/>
   </rest:response>
};

(:~
: REST created http://restpatterns.org/HTTP_Status_Codes/401_-_Unauthorized
:)
declare function http-auth($auth-scheme,$response){
   (
   <rest:response>            
       <http:response status="401" >
	       <http:header name="WWW-Authenticate" value="{$auth-scheme}"/>
	   </http:response>
   </rest:response>,
   $response
   )
};

(:~
: REST created http://restpatterns.org/HTTP_Status_Codes/201_-_Created
:)
declare function http-created($location,$response){
   (
   <rest:response>            
       <http:response status="201" >
	       <http:header name="Location" value="{$location}"/>
	   </http:response>
   </rest:response>,
   $response
   )
};


(:~ CORS header with download option :) 
declare function headers($attachment,$response){
(<restxq:response>
    <http:response>
        <http:header name="Access-Control-Allow-Origin" value="*"/>
    {if($attachment)
    then <http:header name="Content-Disposition" value='attachment;filename="{$attachment}"'/>
    else ()}
    </http:response>
</restxq:response>, $response)
};

(:~ download as zip file :) 
declare function zip-download($zipname,$data){
    (download-response("raw",$zipname), $data)
};

(:~ headers for download  :) 
declare function method($method as xs:string){
<restxq:response>
    <output:serialization-parameters>
        <output:method value="{$method}"/>
    </output:serialization-parameters>
</restxq:response>
};
(:~ headers for download  :) 
declare function download-response($method,$filename){
<restxq:response>
    <output:serialization-parameters>
        <output:method value="{$method}"/>
    </output:serialization-parameters>
   <http:response>
       <http:header name="Content-Disposition" value='attachment;filename="{$filename}"'/> 
    </http:response>
</restxq:response>
};