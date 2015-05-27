/*
 * BenchX angular application
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */ 
angular
  .module(
    'BenchX',
    [  'ngTouch', 'ui.bootstrap', 'ui.router','cfp.hotkeys',
      'ngLogging', 'angularMoment', 'googlechart',
      'log.ex.uo', 'googlechart', 'dialog',
      'ngStorage','smart-table',
      'BenchX.api', 'BenchX.services', 'BenchX.results',
      'BenchX.library','BenchX.benchmark', 'BenchX.suite',
      'services.httpRequestTracker' ])
      
// .config(['$locationProvider',function($locationProvider){
// $locationProvider.html5Mode(true);
// }])
    
  .config(
    [
      '$stateProvider','$urlRouterProvider',
      function($stateProvider,$urlRouterProvider) {
	  $stateProvider
         .state(
           'thisenv',
           {
		    url: "/thisenv",
            templateUrl : '/static/benchx/templates/environment.xhtml',
            controller : "envController",
            resolve : {
             data : function(api) {
              return api
                .thisenv();
             }
            }
           })
           
         .state(
           'about',
           {
		    url: "/about",
            templateUrl : '/static/benchx/templates/about.xhtml'
           })
		   
         .state(
           'log',
           {
		    url: "/log",
            templateUrl : '/static/benchx/templates/log.xhtml'
           })
         
         .state(
           '404',
           {
		    url: "/404",
            templateUrl : '/static/benchx/templates/404.xhtml'
           });
		   
		 $urlRouterProvider.when('', '/about');  
		 $urlRouterProvider.otherwise('/404');  
		   
      } ])

  .config([ 'logExProvider', function(logExProvider) {
   logExProvider.enableLogging(true);
  } ])
 
// ui-router
.run(
  [ '$rootScope', '$state', '$stateParams',
    function ($rootScope,   $state,   $stateParams) {

    // It's very handy to add references to $state and $stateParams to the
    // $rootScope
    // so that you can access them from any scope within your applications.For
    // example,
    // <li ng-class="{ active: $state.includes('contacts.list') }"> will set the
    // <li>
    // to active whenever 'contacts.list' or one of its decendents is active.
    $rootScope.$state = $state;
    $rootScope.$stateParams = $stateParams;
    

    $rootScope.$on('$stateNotFound', 
    function(event, unfoundState, fromState, fromParams){ 
        console.log(unfoundState.to); // "lazy.state"
        console.log(unfoundState.toParams); // {a:1, b:2}
        console.log(unfoundState.options); // {inherit:false} + default options
    });
    
    $rootScope.$on("$stateChangeError", console.log.bind(console));
    }
  ]
)
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
        $window.document.title = t + " BenchX v0.8.10";
       };
       $rootScope.staticRoot="/static/benchx/";
       $rootScope.apiRoot="../../benchx/api/";
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
        $rootScope.serverstate = data;
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
         mode : $rootScope.serverstate.state.mode,
         size : $rootScope.serverstate.state.size
        }).then(function(res) {
         results.addRun(index, res);
         
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
       function makerun(generator,mode, factor,repeat) {
        var tasks = [ {
         cmd : "state",
         data : {
           generator : generator, 
          mode : mode,
          factor : factor
         }
        } ];
        angular.forEach($rootScope.results.data().queries,
          function(v, index) {
          for (var i = 0; i < repeat; i++) {
           tasks.push({
            cmd : "run",
            data : index
           });
          };
       });
        return tasks;
       };
       $scope.$storage = $localStorage.$default({
        settings : {
         mode : "F",
         factor : 0,
         allmodes : true,
         doIncr : false,
         incr : 0.25,
         repeat : 1,
         maxfactor : 1,
         generator:"xmlgen"
        }
       });
       
       $scope.generators=[        
         {value:"xmlgen",label:"xmlgen"},
         {value:"xmlgen400",label:"xmlgen /s400"},
         {value:"-",label:"(use found)"}
       ];
       
       $scope.executeAll = function() {
        var settings = $scope.$storage.settings;
        var q=$rootScope.tasks.q;
         var f = settings.factor;
         do {
          var m = settings.mode;
          q.push(makerun(settings.generator,m, f,settings.repeat));
          if (settings.allmodes) {
           m = (m == "F") ? "D" : "F";
           q.push( makerun(settings.generator,m, f));
          }
          ;
          f += settings.incr;
         } while (settings.doIncr
           && f <= settings.maxfactor);
        
        $scope.setView("graph");
       };
       $scope.setNow = function() {
        var settings = $scope.$storage.settings;
        $rootScope.tasks.q.push({
         cmd : "state",
         data : {
          mode : settings.mode,
          factor : settings.factor,
          generator : settings.generator
         }
        });

       };
      } ])
      
  .controller('envController',
    [ "$scope", "data", function($scope, data) {
     $scope.setTitle("Environment");
     $scope.environment = data;
    } ])



  