declare  variable $body external :="{body}";
declare  variable $version external :="{verson}";
declare variable $base external :="/benchx/";
declare variable $static external :="/static/benchx/";
declare variable $incl-css as element()* external :=();
declare variable $incl-js as element()* external :=();


<html ng-app="BenchX" ng-controller="rootController">
<head>
<meta charset="utf-8" />
 <base href="{$base}" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta name="description" content="Benchmark for BaseX" />
<meta name="author" content="andy bunce." />
<title>BenchX (v{$version})</title>
<link rel="shortcut icon" href="{$static}benchx-64x64.png" />
<!-- component css -->
{$incl-css}

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
    <!-- start component js -->
    {$incl-js}
     <!-- app js -->
      <script src="{$static}app.js"></script>
    <script src="{$static}api.js"></script>
    <script src="{$static}services.js"></script>
    <script src="{$static}feats/library/library.js"></script>
    <script src="{$static}feats/suite/suite.js"></script>
    <script src="{$static}results.js"></script>
    <script src="{$static}benchmark.js"></script>
</body>
</html>