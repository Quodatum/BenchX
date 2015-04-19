declare  variable $body external :="{body}";
declare  variable $version external :="{verson}";
declare variable $base external :="/static/benchx/";
declare variable $static external :="/static/benchx/";


<html ng-app="BenchX" ng-controller="rootController">
<head>
<meta charset="utf-8" />
 <base href="{$base}" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta name="description" content="Benchmark for BaseX" />
<meta name="author" content="andy bunce" />
<title>BenchX (v{$version})</title>
<link rel="shortcut icon" href="{$static}benchx-64x64.png" />
<link
    href="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.4/css/bootstrap.min.css"
    rel="stylesheet" type="text/css" />
<link href="//cdnjs.cloudflare.com/ajax/libs/angular-hotkeys/1.4.5/hotkeys.css" rel="stylesheet"
    type="text/css" />
<link href="{$static}app.css" rel="stylesheet" type="text/css" />
<link href="{$static}xqdoc.css" rel="stylesheet" type="text/css" />
<script type="text/javascript">
  (function(i,s,o,g,r,a,m){{i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){{
  (i[r].q=i[r].q||[]).push(arguments)}},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  }})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-51544119-2', 'auto');
</script>   
</head>
<body  >
    {$body}
     <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular.min.js"  ></script>
    <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular-resource.min.js"  ></script>
    <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular-cookies.min.js"  ></script>
    <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular-sanitize.min.js"></script> 
    <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular-route.min.js"></script> 
    <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular-animate.min.js"></script> 
    <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular-touch.min.js"></script>   
    <script
        src="//cdnjs.cloudflare.com/ajax/libs/angular-ui-bootstrap/0.12.0/ui-bootstrap-tpls.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/lodash.js/2.4.1/lodash.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/async/0.8.0/async.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/moment.js/2.6.0/moment-with-langs.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/angular-moment/0.7.0/angular-moment.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/stacktrace.js/0.6.0/stacktrace.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/angular-hotkeys/1.4.5/hotkeys.js"></script>
 
   
    <script src="{$static}../lib/ngStorage/0.3.0/ngStorage.js"></script>    
    <script src="{$static}../lib/AngularLogExtender/0.0.10/log-ex-unobtrusive.min.js"></script>
    <script src="{$static}../lib/angular-logging.js"></script>

   <script src="{$static}../lib/smart-table/1.4.9/smart-table.min.js"></script>
    <script src="{$static}../lib/googlechart/0.0.11/ng-google-chart.js"></script>
    
    <script src="{$static}../lib/httpRequestTracker.js"></script>
    <script src="{$static}../lib/interceptor400.js"></script>
    <script src="{$static}../lib/FileSaver.js"></script>
    <script src="{$static}../lib/dialog.js"></script>
    <script src="{$static}app.js"></script>
    <script src="{$static}api.js"></script>
    <script src="{$static}services.js"></script>
    <script src="{$static}feats/library/library.js"></script>
    <script src="{$static}feats/suite/suite.js"></script>
    <script src="{$static}results.js"></script>
    <script src="{$static}benchmark.js"></script>
</body>
</html>