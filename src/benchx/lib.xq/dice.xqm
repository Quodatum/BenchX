(:~ 
: dice utils - sort, filter, and serialize as json.
: can read parameters from request: sort,start,limit.
: @author andy bunce
: @since mar 2013
:)

module namespace dice = 'quodatum.web.dice/v2';
declare default function namespace 'quodatum.web.dice/v2'; 
declare namespace restxq = 'http://exquery.org/ns/restxq';
import module namespace request = "http://exquery.org/ns/request";

(:~ 
 : sort items
 : @param sort  field name to sort on optional leading +/-
 : @return sorted items 
 :)
declare function sort($items as item()*
                     ,$fmap as map(*)
                     ,$sort as xs:string?)
as item()*{
  let $sort:=fn:normalize-space($sort)
  let $ascending:=fn:not(fn:starts-with($sort,"-"))
  let $fld:=fn:substring($sort,if(fn:substring($sort,1,1)=("+","-")) then 2 else 1)
  return if(fn:not(map:contains($fmap, $fld))) then
            $items
          else if ($ascending) then
            for $i in $items
            let $i:=fn:trace($i,"feld " || $fld )
            order by $fmap($fld)($i) ascending
            return $i
          else
            for $i in $items 
            order by  $fmap($fld)($i) descending
            return $i
};

(:~ generate item xml for all fields in map :)
declare function json-flds($item,$fldmap)
{
  json-flds($item,$fldmap,map:keys($fldmap)) 
};

(:~ generate item xml for some fields in map :)
declare function json-flds($item as element(),
                           $fldmap as map(*),
						   $keys as xs:string*)
as element(_){ 
    <_> 
    {for $key in $keys 
	return element {$key}{
    try{
       $fldmap($key)($item)
    }catch * {
       $err:description
    }} }
	</_>
};


(:~ 
 : sort, slice, return json using request parameters
 : @param $items sequence of source items
 :)
declare function response($items,$entity as map(*),$crumbs){
  let $total:=fn:count($items)
  let $sort:=request:parameter("sort","")
  let $items:= dice:sort($items,map:get($entity,"access"),$sort)
  
  let $start:=xs:integer(fn:number(request:parameter("start","0")))
  let $limit:=xs:integer(fn:number(request:parameter("limit","30")))
  let $jsonf:= map:get($entity,"json")
  let $fields:=map:keys($jsonf)
  let $_:=fn:trace($total,"response: ")
  return 
  <json objects="json _" >
    <total type="number">{$total}</total>
    <entity>{$entity("name")}</entity>
    {if($crumbs) then <crumbs type="array">{$crumbs}</crumbs> else() }
    <items type="array">
        {for $item in fn:subsequence($items,1+$start,$limit)
        return <_ >{$fields!$jsonf(.)($item)}</_>}
    </items>
  </json> 
};

(:~ 
 : sort, slice, return json
 :)
declare function response($items,$entity as map(*)){
    response($items,$entity,())
};

