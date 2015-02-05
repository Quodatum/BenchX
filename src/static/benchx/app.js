/*
 * BenchX angular application
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */ 
angular
  .module(
    'BenchX',
    [ 'ngRoute', 'ngTouch', 'ui.bootstrap', 'cfp.hotkeys',
      'ngLogging', 'angularMoment', 'googlechart',
      'log.ex.uo', 'googlechart', 'dialog',
      'ngStorage','smart-table',
      'BenchX.api', 'BenchX.services', 'BenchX.results',
      'BenchX.library','BenchX.suite','BenchX.benchmark',
      'services.httpRequestTracker' ])

  .config(
    [
      '$routeProvider',
      "$injector",
      function($routeProvider, $injector) {
       $routeProvider
         .when('/', {
          redirectTo : '/about'

         })
         
         .when(
           '/thisenv',
           {
            templateUrl : '/static/benchx/templates/environment.xhtml',
            controller : "envController",
            resolve : {
             data : function(api) {
              return api
                .thisenv();
             }
            }
           })
           
         .when(
           '/about',
           {
            templateUrl : '/static/benchx/templates/about.xhtml'
           })
         .when(
           '/log',
           {
            templateUrl : '/static/benchx/templates/log.xhtml'
           })
         
         .when(
           '/doc/:view',
           {
            templateUrl : '/static/benchx/templates/doc.xhtml',
            controller : "DocController"
           })
           
         .when(
           '/404',
           {
            templateUrl : '/static/benchx/templates/404.xhtml'
           }).otherwise({
          redirectTo : '/404'
         });
      } ])

  .config([ 'logExProvider', function(logExProvider) {
   logExProvider.enableLogging(true);
  } ])

  // .config([ 'Logging', function(Logging) {
  // Logging.enabled=true;
  // } ])
  .run(
    [
      '$rootScope',
      '$window',
      '$log',
      'Logging',
      "$localStorage",
      'results',
      'taskqueue',
      function($rootScope, $window,$log, Logging,$localStorage,results,taskqueue) {
       Logging.enabled = true;
       $rootScope.$storage = $localStorage.$default({
           activesuite: "xmark"
       });
       $rootScope.setTitle = function(t) {
        $window.document.title = t + " BenchX v0.7.0";
       };
       $rootScope.results=results;
       $rootScope.tasks=taskqueue;
       $rootScope.setTitle("BenchX");
       $rootScope.logmsg = "Welcome to BenchX";

       $rootScope.activesuite = $rootScope.$storage.activesuite;
       $rootScope.meta = {
        title : ""
       };
       
       
       
      } ])
      
  .run(['hotkeys','$location','$rootScope',function(hotkeys,$location,$rootScope){
   hotkeys.add("l", "Go to library",function(){
          return $location.url("/library");});
   hotkeys.add("e", "Go to environments",function(){
          return $location.url("/environment");});
   hotkeys.add("s", "Go to suites",function(){
          return $location.url("/suite");});
   hotkeys.add("r", "Go to run",function(){
          return $location.url("/suite/"+$rootScope.activesuite+"/session?view=run");});
  }])

  .controller(
    'rootController',
    [
      '$rootScope',
      'api',
      'utils',
      '$log',
      function($rootScope, api, utils, $log) {
       function updateStatus(data) {
        $log.log("update status:", data);
        $rootScope.state = data.state;
       }

       $rootScope.$watch("session", function() {
        // to kick charts to update
        $rootScope.$broadcast("session");
       }, true);

       // run query with index
       $rootScope.execute = function(index) {
           var results=$rootScope.results;
        var q = results.data().queries[index];
        return api.execute({
         suite : $rootScope.activesuite,
         name : q.name,
         mode : $rootScope.state.mode,
         size : $rootScope.state.size
        }).then(function(res) {
         results.addRun(index, res.run);
         
        }, function(reason) {
         alert("Execution error" + reason.data);
        });
       };

       $rootScope.saveAs = function() {
        var csv = utils.csv(results.data(),
          $rootScope.activesuite);
        saveAs(csv, "results.csv");
       };

       $rootScope.setState = function(data) {
        return api.stateSave(data).then(
          function(d) {
           api.state().then(updateStatus);
          },
          function(reason) {
           alert("Failed to set state\n"
             + reason.data);
          });
       };
       
       api.suites().then(function(data) {
        $log.log("suites:", data);
        $rootScope.suites = data;
       });

       api.state().then(updateStatus);

      } ])

  .controller(
    'SessionController',
    [
      "$scope",
      '$rootScope',
      '$routeParams',
      "$location",
      "$dialog",
      "api",
      "data",
      function($scope,$rootScope, $routeParams, $location, $dialog, api,
        data) {
       console.log("SessionController", data);
       $scope.session = data;
       $scope.setTitle("Session: " + $scope.activesuite);
       $scope.meta = {
        title : "",
        suite:$scope.activesuite
        }; 
       

       $scope.setView = function(v) {
        $scope.view = v;
        $location.search("view", v);
       };
       $scope
         .setView($routeParams.view ? $routeParams.view
           : "grid");

       $scope.clearAll = function() {
        var msg = "Remove timing data for runs in the current session?";
        $dialog.messageBox("clear all", msg, [],
          function(result) {
           if (result === 'OK') {
           var d = new api.session();
           d.delete().$promise.then(function(a) {
            $rootScope.results.clear();
            $rootScope.logmsg = "session data deleted.";
           }, function(e) {
            alert("FAILED: " + e.data);
           }); 
           }
          });
       };
       
       $scope.save = function() {
        var d = new api.session();
        d.save($scope.meta).$promise.then(function(a) {
         $rootScope.logmsg = "Saved to library: "+a.id;
         $location.path("/library/item/"+a.id);
        }, function(e) {
         alert("FAILED: " + e.data);
        });
       };
      } ])

  .controller(
    'ScheduleController',
    [
      "$scope",
      "$rootScope",
      "api",
      "$localStorage",
      "$log",
      function($scope, $rootScope, api, $localStorage, $log) {
       // return array of tasks to set state then run each
                            // query
       function makerun(mode, factor) {
        var tasks = [ {
         cmd : "state",
         data : {
          mode : mode,
          factor : factor
         }
        } ];
        angular.forEach($rootScope.results.data().queries,
          function(v, index) {
           tasks.push({
            cmd : "run",
            data : index
           });
          });
        return tasks;
       }
       ;
       $scope.$storage = $localStorage.$default({
        settings : {
         mode : "F",
         factor : 0,
         allmodes : true,
         doIncr : false,
         incr : 0.25,
         repeat : 1,
         maxfactor : 1
        }
       });

       $scope.executeAll = function() {
        var settings = $scope.$storage.settings;
        var q=$rootScope.tasks.q;
        for (var i = 0; i < settings.repeat; i++) {
         var f = settings.factor;
         do {
          var m = settings.mode;
          q.push(makerun(m, f));
          if (settings.allmodes) {
           m = (m == "F") ? "D" : "F";
           q.push( makerun(m, f));
          }
          ;
          f += settings.incr;
         } while (settings.doIncr
           && f <= settings.maxfactor);
        }
        ;
        $scope.setView("graph");
       };
       $scope.setNow = function() {
        var settings = $scope.$storage.settings;
        $rootScope.tasks.q.push({
         cmd : "state",
         data : {
          mode : settings.mode,
          factor : settings.factor
         }
        });

       };
      } ])
  .controller('envController',
    [ "$scope", "data", function($scope, data) {
     $scope.setTitle("Environment");
     $scope.environment = data;
    } ])

  .controller(
    "ChartController",
    [
      '$scope',
      '$rootScope',
      '$window',
      'utils',
      function($scope, $rootScope, $window, utils) {
       $scope.setTitle("Graph");
       $scope.session = $rootScope.results.data();
       function genChart() {
           var options={
        title:'BenchX: ' + $scope.session.name + " " + $rootScope.meta.title,
         vAxis: {title: 'Time (sec)'},
         hAxis: {title: 'Query'}
         };
           console.log("CHART ",$scope.session.queries);
        return $scope.session?utils.gchart($scope.session.queries,options):null;
       }
       ;

       $scope.chartReady = function(chartWrapper) {
        // not working!!
        $window.google.visualization.events
          .addListener(
            chartWrapper,
            'select',
            function() {
             $log
               .log('select event fired!');
            });
       };
       $scope.$on("session", function() {
        $scope.chartObject = genChart();
       });
       $scope.chartObject = genChart();
      } ])

  .controller(
    'DocController',
    [
      "$scope",
      "$routeParams",
      "$location",
      "$anchorScroll",
      "$log",
      function($scope, $routeParams, $location,
        $anchorScroll, $log) {
       $log.log("View:", $routeParams.view);
       var map = {
        "xqdoc" : '/doc/app/benchx/server/xqdoc',
        "wadl" : '/doc/app/benchx/server/wadl',
        "components" : '/doc/app/benchx/client/components',
        "templates" : '/doc/app/benchx/client/templates',
        "xqdoc2" : 'doc/server'
       };
       $scope.view = $routeParams.view;
       $scope.inc = map[$routeParams.view];
       $scope.setTitle("docs");
       $scope.scrollTo = function(id) {
        $log.log("DDDD", id);
        $location.hash(id);
        // call $anchorScroll()
        $anchorScroll();
       };
      } ])
      ;
