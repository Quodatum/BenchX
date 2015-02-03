/*
 * library handler
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.suite', [ 'ngResource', 'ngRoute', 'BenchX.api' ])
    .config(
        [ '$routeProvider', "$injector", function($routeProvider, $injector) {

          $routeProvider

          .when('/suite', {
            templateUrl : '/static/benchx/feats/suite/suites.xml',
            controller : "SuitesController",
            resolve : {
              data : function(api) {
                return api.suites();
              }
            }

          })

          .when('/suite/:id', {
            templateUrl : '/static/benchx/feats/suite/suite.xml',
            controller : "SuiteController",
            resolve : {
              data : function(api, $route) {
                return api.suite($route.current.params.id);
              }
            }
          })

          .when('/suite/:suite/session', {
            templateUrl : '/static/benchx/feats/suite/session.xml',
            controller : "SessionController",
            resolve : {
              data : function(results, $route) {
                return results.promise($route.current.params.suite);
              }
            }
          })

          .when('/suite/:suite/library', {
            templateUrl : '/static/benchx/templates/library.xhtml',
            controller : "LibraryController",
            /*
             * resolve: $injector.get('LibraryResolve')
             */
            resolve : {
              data : function(api, $route) {
                return api.suite($route.current.params.suite);
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
        [ "$scope", "$rootScope", "data", "$routeParams",
            function($scope, $rootScope, data, $routeParams) {
              $rootScope.activesuite = $routeParams.id;
              $scope.setTitle("Suite: " + $routeParams.id);
              $scope.suite = data;
            } ]);
