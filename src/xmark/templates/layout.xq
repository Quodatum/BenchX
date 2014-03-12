declare  variable $body external;
declare  variable $version external;
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
            
            <a class="navbar-brand" href=".">XMark</a>
            <p class="navbar-text">queries timed using</p>
            <p class="navbar-text">BaseX:{$version}</p>
          </div>
          </div>
          </div>
{$body}
</div>
</body>
</html>