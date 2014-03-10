declare  variable $size external;
declare  variable $db external;
 <div>
   <div>auction file size:{$size}</div>
   <div> db 'xmark': {$db}</div>
  
    <form method="post" action="xmark/results" role="form">
    <button class="btn btn-primary" type="submit" >run XMark</button>
     <label>Timeout (secs):
    <input type="number" name="timeout" value="15"/>
    </label>
    </form>
    <hr/>
     <form method="post" action="xmark/xmlgen" role="form">
    <label>Factor:
    <input type="number" name="factor" value="0.5"/>
    </label>
   
    <button class="btn btn-primary" type="submit" >run XMLgen</button>
    </form>
    
    <form method="post" action="xmark/manage">
    <button class="btn btn-primary" type="submit" >create db</button>
    </form>
    </div>