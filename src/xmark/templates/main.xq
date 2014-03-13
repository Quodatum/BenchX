declare  variable $size external;
declare  variable $db external;
declare  variable $env external;
 <div>
   <div>auction file size:{$size}</div>
   <div> db 'xmark': {$db}</div>
 
    <form method="post" action="/xmark/results" role="form" class="form-inline">
    <button class="btn btn-primary" type="submit" >run XMark</button>
     <label>Timeout (secs):
    <input type="number" name="timeout" value="15"/>
    </label>
    <label>Repeat:
    <input type="number" name="repeat" value="1"/>
    </label>
    </form>
    
 
     
     <form method="post" action="/xmark/xmlgen" role="form" class="form-inline">
    <label>Factor:
    <input type="number" name="factor" value="0.5"/>
    </label>
   
    <button class="btn btn-primary" type="submit" >run XMLgen</button>
    </form>
  
    <form method="post" action="xmark/manage" class="form-inline">
    <button class="btn btn-primary" type="submit" >create db</button>
    </form>
    <div class="col-xs-6">{$env}</div>
    </div>