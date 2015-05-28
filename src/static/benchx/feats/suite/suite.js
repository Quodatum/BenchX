/*
 * library handler
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.suite', [ 'ngResource', 'ui.router', 'BenchX.api','BenchX.services' ])
    .config(
        [ '$stateProvider', '$urlRouterProvider',
            function($stateProvider, $urlRouterProvider) {
              $stateProvider
              
              .state('suite', {
                url : '/suite',
                abstract: true,
                template: '<ui-view>suites</ui-view>'
              })
              
              .state('suite.index', {
                url : '',
                templateUrl : '/static/benchx/feats/suite/suites.xml',
                controller : "SuitesController",
                resolve : {
                  data : function(api) {
                    return api.suites();
                  }
                }
                  
              })
              
               .state('suite.id', {
                url : '/:suite',
                abstract: true,
                template: '<ui-view>suite</ui-view>'
              })
              
              .state('suite.id.item', {
                url : '',
                templateUrl : '/static/benchx/feats/suite/suite.xml',
                controller : "SuiteController",
                resolve : {
                  data : function(api, $stateParams) {
                    console.log("suite");
                    return api.suite($stateParams.suite);
                  }
                }
              })

               .state('suite.id.session', {
                url : '/session',
                templateUrl : '/static/benchx/feats/suite/session.xml',
                controller : "SessionController",
                resolve : {
                  data : function(results, $stateParams) {
                    return results.promise($stateParams.suite);
                  }
                }
              })
               .state('suite.id.session.grid', {
                url : '/grid',
                templateUrl : '/static/benchx/feats/suite/grid.xml',
              })
			  
              .state('suite.id.session.save', {
                url : '/save',
                templateUrl : '/static/benchx/feats/suite/save.xml',
                controller : "SessionController",
                resolve : {
                  data : function(results, $stateParams) {
                    return results.promise($stateParams.suite);
                  }
                }
              })
              .state('suite.id.session.run', {
                url : '/run',
                templateUrl : '/static/benchx/feats/suite/schedule.xml',
              })
			  
			  .state('suite.id.session.graph', {
                url : '/graph',
                templateUrl : '/static/benchx/feats/suite/graph.xml',
                controller:"ChartController"
                })
              .state('suite.id.library', {
                url : '/library',
                templateUrl : '/static/benchx/templates/library.xhtml',
                controller : "LibraryController",
                /*
                 * resolve: $injector.get('LibraryResolve')
                 */
                resolve : {
                  data : function(api, $stateParams) {
                    return api.suite($stateParams.suite);
                  }

                }
              })
            } ])

    .controller('SuitesController', [ "$scope", "data", function($scope, data) {
      $scope.setTitle("Suites");
      $scope.suites = data;
    } ])

    .controller(
        'SuiteController',
        [ "$scope", "$rootScope", "data", "$stateParams",
            function($scope, $rootScope, data, $stateParams) {
              $rootScope.activesuite = $stateParams.id;
              $scope.setTitle("Suite: " + $stateParams.id);
              $scope.suite = data;
            } ])
            
     .controller(
    'SessionController',
    [
      "$scope",
      '$rootScope',
      '$stateParams',
      "$location",
      "$dialog",
      "api",
      "data",
      function($scope,$rootScope, $stateParams, $location, $dialog, api,
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
         .setView($stateParams.view ? $stateParams.view
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
           };
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
    "ChartController",
    [
      '$scope',
      '$rootScope',
      '$window',
      'utils',
      function($scope, $rootScope, $window, utils) {
        console.log("Chart controler");
       
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
            
            ;
