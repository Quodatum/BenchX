xquery version "3.0";
(:~
: bootstrap utilities
:
: @author andy bunce
: @since mar 2014
: @licence apache 2
:)
 
module namespace bootstrap = 'apb.basex.bootstrap';
declare default function namespace 'apb.basex.bootstrap';

declare function property-table($names,$getFun){
<table class="table table-striped">
<thead><tr><th>Name</th><th>Value</th></tr></thead>
<tbody>
{for $p in $names return <tr><td>{$p}</td>
                                <td>{$getFun($p)}</td>
                             </tr>}
</tbody>
</table>
};

declare function panel($title,$body){
<div class="panel panel-default">
  <div class="panel-heading">
    <h3 class="panel-title">{$title}</h3>
  </div>
  <div class="panel-body">
    {$body}
  </div>
</div>
};