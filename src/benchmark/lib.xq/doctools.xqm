xquery version "3.0";
(:~
: xqdoc utils
:
: @author andy bunce
: @since may 2014
: @licence apache 2
:)
 
module namespace env = 'apb.xqdoc';
declare default function namespace 'apb.xqdoc';

declare function generate-html($src)
{
let $doc:=inspect:xqdoc($src)
return xslt:transform($doc,fn:resolve-uri("xqdoc.xsl"))
};