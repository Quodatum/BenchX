(: evaluate xmark test :)
declare namespace sys="java.lang.System";

declare function local:time-xmark(
  $index
){
  let $f:=resolve-uri(
    "queries/q" || $index || ".xq"
  )
  let $xq:=fn:unparsed-text(
    $f
  )
  let $t1:=prof:current-ms()
  let $bindings:=map{}
  let $opts:=map {
     "permission" := "create","timeout":=10
  }
  let $r:=try{
    xquery:eval($xq,$bindings,$opts)
  }catch * 
  {
    -1
  }
  return prof:current-ms()-$t1
};
let $res:=( 1 to 20)!local:time-xmark(.)
let $java:=("java.version",
            "java.vendor",
            "java.vm.version","java.vm.specification.version",
            "os.name","os.version")!sys:getProperty(.)
return ($java)