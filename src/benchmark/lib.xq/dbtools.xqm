(:~ 
: tools for databases..
: @author andy bunce
: @since mar 2013
:)

module namespace dbtools = 'apb.dbtools';
declare default function namespace 'apb.dbtools'; 

(:~ 
: save all in db to zip
: no binary yet 
:)
declare function zip($dbname as xs:string)
as xs:base64Binary{
  let $files:=db:list($dbname)
  let $zip   := archive:create(
                  $files ! element archive:entry { . },
                  $files ! fn:serialize(db:open($dbname, .))
                  )
return $zip
};

(:~
: update or create database from file path
: @param $dbname name of database
: @param $path file path contain files
:)
declare %updating function sync-from-path(
                                    $dbname as xs:string,
                                    $path as xs:string)
 {
  sync-from-files($dbname,
                  $path,
                  file:list($path,fn:true()),
                  hof:id#1)
};

(:~
: update or create database from file list
: @param $dbname name of database
: @param $path  root file path for files are relative 
: @param $files file names from base
: @param filter a function to apply to items in $files, maybe to remove some.
:)
declare %updating function sync-from-files(
    $dbname as xs:string,
    $path as xs:string,
    $files as xs:string*,
    $filter as function(*)
){
let $path:=$path || file:dir-separator()
return if(db:exists($dbname)) then
       (
       for $d in db:list($dbname) 
       where fn:not($d=$files) 
       return db:delete($dbname,$d),
       
       for $f in $files 
       let $full:=$filter($path || $f) 
       return db:replace($dbname,$f,$full),
       
       db:optimize($dbname)
       )
       else
        let $full:=$files!fn:concat($path,.)!$filter(.) 
        return (db:create($dbname,$full,$files))
};