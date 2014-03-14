declare  variable $body external;
declare  variable $version external;
declare  variable $mode external;
declare  variable $size external;
declare  variable $error external;
<html>
<head>
 <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <meta name="description" content="XMark for BaseX"/>
    <meta name="author" content="andy bunce"/>
<title>XMark tests</title>
<link href="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.0.3/css/bootstrap.css" rel="stylesheet" type="text/css" />  
</head>
<body> 
<div class="container">
      <div class="navbar navbar-inverse" role="navigation">
        <div class="container-fluid">
          <div class="navbar-header">
            
            <a class="navbar-brand" href="/xmark/">XMark</a>
            <p class="navbar-text">queries timed using</p>
            
            <p class="navbar-text">BaseX:{$version}</p>
            <form method="post" action="/xmark/manage" class="navbar-form navbar-left">
            <button class="btn btn-primary" type="submit" 
            title="Click to toggle mode: File or Database">{$mode}</button>
            </form>
            <h3 class="navbar-text"><span class="label label-default">{$size}</span></h3>
     
          </div>
         </div>
        </div>
        <div class="alert alert-error ">{$error}</div>
        
{$body}
</div>
</body>
</html>