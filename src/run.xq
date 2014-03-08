(: evaluate xmark test :)
declare function local:time(
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
    xquery:eval(
      $xq,$bindings,$opts
    )
  }catch * 
  {
    -1
  }
  return prof:current-ms()-$t1
};
( 1 to 20)!local:time(.)