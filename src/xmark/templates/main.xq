declare  variable $env external;
 <div>
    <p>Run all queries</p>
    <form method="post" action="/xmark/results" role="form" class="well form-inline">
    <button class="btn btn-primary" type="submit" >run XMark</button>
     <label>Timeout (secs):
    <input type="number" name="timeout" value="15"/>
    </label>
    <label>Repeat (@TODO):
    <input type="number" name="repeat" value="1"/>
    </label>
    </form>
    <div class="col-xs-6">{$env}</div>
    </div>