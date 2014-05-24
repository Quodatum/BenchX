xquery version "3.0";
(:~
: Get information about the BaseX ,java and host environment
: using java api calls
:
: @author andy bunce
: @since sept 2012
: @licence apache 2
:)
 
module namespace env = 'apb.basex.env';
declare default function namespace 'apb.basex.env';
declare namespace sys="java.lang.System";
declare namespace Runtime="java.lang.Runtime";
declare namespace ManagementFactory="java.lang.management.ManagementFactory";
declare namespace RuntimeMXBean="java.lang.management.RuntimeMXBean";
declare namespace InetAddress="java.net.InetAddress";

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
(: 
 : memory status
 :http://javarevisited.blogspot.co.uk/2012/01/find-max-free-total-memory-in-java.html
:)
declare function memory($human as xs:boolean)
as map(*){
let $f:=if($human)then prof:human#1 else function($x){$x}
let $r:=Runtime:getRuntime()
return map{
    "runtime.freeMemory":=$f(Runtime:freeMemory($r)),
    "runtime.maxMemory":=$f(Runtime:maxMemory($r)),
    "runtime.totalMemory":=$f(Runtime:totalMemory($r))
    }
};

(:~ useful properties as a map :)
declare function about() 
as map(*){
 let $c:= map:new($env:core!map:entry(.,sys:getProperty(.)))
 return map:new((
                $c,
                memory(fn:true()),
                map:entry("basex.version",basex-version()),
                map:entry("runtime.availableProcessors",availableProcessors())
                ))
};

declare function availableProcessors()
{
    let $r:=Runtime:getRuntime()
    return Runtime:availableProcessors($r)
};

declare function uptime()
{
    let $r:=ManagementFactory:getRuntimeMXBean()
    return RuntimeMXBean:getUptime($r)
};

declare function hostname() as xs:string
{
try{
    let $r:=InetAddress:getLocalHost()
    return InetAddress:getHostName($r)
} catch *{
    "?"   
    }

};