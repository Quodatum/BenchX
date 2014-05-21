xquery version "3.0";
(:~
: xqdoc utils
:
: @author andy bunce
: @since may 2014
: @licence apache 2
:)
 
module namespace doc = 'apb.doc';
declare default function namespace 'apb.doc';

import module namespace rest = 'http://exquery.org/ns/restxq';

declare function generate-html($src)
{
    let $doc:=inspect:xqdoc($src)
    return xslt:transform($doc,fn:resolve-uri("xqdoc.xsl"))
};

declare function wadl($root)
{
    let $doc:=rest:wadl()
    let $params:=map { "root" := $root }
    return xslt:transform($doc,fn:resolve-uri("wadl.xsl"),$params)
};