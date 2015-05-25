/*
 * library handler
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.suite', [ 'ngResource', 'ui.router', 'BenchX.api' ])
    .config(
        [ '$stateProvider', '$urlRouterProvider',
            function($stateProvider, $urlRouterProvider) {
              $stateProvider.state('suite', {
                url : '/suite',
                abstract: true,
                template: '<ui-view/>'
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
                url : '/:id',
                templateUrl : '/static/benchx/feats/suite/suite.xml',
                controller : "SuiteController",
                resolve : {
                  data : function(api, $stateParams) {
                    console.log("suite");
                    return api.suite($stateParams.id);
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
            } ]);
