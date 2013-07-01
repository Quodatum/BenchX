declare function local:time($index){
  let $f:=resolve-uri("queries/q" || $index || ".xq")
  let $t1:=prof:current-ms()
  let $r:=xquery:invoke($f)
  return prof:current-ms()-$t1
};
local:time(11)