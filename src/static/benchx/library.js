/*
 * library handler
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.library', [ 'ngResource','ngRoute','BenchX.api' ])

.config([ '$routeProvider', function($routeProvider) {
	$routeProvider.when('/library', {
		templateUrl : '/static/benchx/templates/library.xhtml',
		controller : "LibraryController",
		resolve : {
			data : function(api) {
				return api.library().query().$promise;
			}
		}

	}).when('/library/:id', {
		templateUrl : '/static/benchx/templates/record.xml',
		controller : "RecordController",
		resolve : {
			data : function(api, $route) {
				var id = $route.current.params.id;
				return api.library().get({
					id : id
				}).$promise;
			}
		}

	});
} ])

.controller(
		'LibraryController',
		[ "$scope", "$rootScope", "data", "$log",
				function($scope, $rootScope, data, $log) {
					$scope.setTitle("Library");
					$scope.docs = data;
					$log.log("DDDDDDDD",data);
					$scope.swipe = function() {
						alert("TODO swipe");
					};
					$scope.libzip = function() {
						alert("TODO");
					};
				} ])

.controller(
		'RecordController',
		[
				"$scope",
				"$rootScope",
				"data",
				"$routeParams",
				"$location",
				"utils",
				function($scope, $rootScope, data, $routeParams, $location,
						utils) {
					$scope.setTitle("Record");
					$scope.benchmark = data.benchmark;
					console.log("benchmark: ",$scope.benchmark);
					//@TODO Extract names of factor
					var states=_.uniq(data.benchmark.runs,function(run){return run.mode + run.factor});
					$scope.states=_.map(states,function(run){return run.mode + run.factor});
					var queries=_.uniq(data.benchmark.runs,function(run){return run.name});
					$scope.queries=_.map(queries,function(run){return run.name});
					$scope.getRuns=function(state,query){
						return _.filter(data.benchmark.runs,function(run){
									var r= (run.name==query) && (state==run.mode + run.factor);
									console.log("**",run.name,query,run.mode,state);
									return r;
									});
						};
					$scope.setView = function(v) {
						$scope.view = v;
						$location.search("view", v);
					};
					$scope.setView($routeParams.view ? $routeParams.view
							: "grid");
					$scope.drop = function() {
						alert("TODO");
						var id = $scope.benchmark.id;
						$scope.record.$delete({
							id : id,
							password : "AAA"
						}).then(function(a) {
							alert("A");
						}, function(a) {
							alert("B");
						});
					};
					var d = [];
					// angular.foreach(data.benchmark.runs)
					//$scope.chartObject = utils.gchart(data.benchmark,"test");
				} ]);
