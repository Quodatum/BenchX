xquery version "3.0";
(:~
: Get information about the BaseX environment, often java properties
:
: @author andy bunce
: @since sept 2012
: @licence apache 2
:)
 
module namespace env = 'apb.basex.env';
declare default function namespace 'apb.basex.env';
declare namespace sys="java.lang.System";
declare variable $env:core:=(
            "java.version","java.vendor","java.vm.version",
            "os.name","os.version","os.arch");
            
(:~ @return BaseX version string :)
declare function basex-version() as xs:string{
db:system()/generalinformation/version
};

(:~ 
 : @return true if basex version is at least $minver e.g "7.8" 
 :)
declare function basex-minversion($minver as xs:string) as xs:boolean{
 let $v:=fn:substring-before(basex-version()," ")
 return fn:substring($v,1,fn:string-length($minver)) ge $minver
};

declare function getProperty($name as xs:string) as xs:string{
    sys:getProperty($name)
};

(:~ useful java properties :)
declare function about(){
  $env:core!sys:getProperty(.)
};