declare  variable $env external;
 <div>
    <p>Run all queries</p>
    <form method="post" action="/xmark/results" role="form" class="form-inline">
    <button class="btn btn-primary" type="submit" >run XMark</button>
     <label>Timeout (secs):
    <input type="number" name="timeout" value="15"/>
    </label>
    <label>Repeat:
    <input type="number" name="repeat" value="1"/>
    </label>
    </form>
    <p>Run XMLgen to generate a file using the given factor. 
    Any existing database will be dropped.</p>     
     <form method="post" action="/xmark/xmlgen" role="form" class="form-inline">
    <label>Factor:
    <input type="number" name="factor" value="0.5"/>
    </label>  
    <button class="btn btn-primary" type="submit" >run XMLgen</button>
    </form>

    <div class="col-xs-6">{$env}</div>
    </div>