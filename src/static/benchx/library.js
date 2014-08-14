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
					$log.log("DDDDDDDD");
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
					$scope.record = data;
					$scope.setView = function(v) {
						$scope.view = v;
						$location.search("view", v);
					};
					$scope.setView($routeParams.view ? $routeParams.view
							: "grid");
					$scope.drop = function() {
						alert("TODO");
						var id = $scope.record.benchmark.id;
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
					$scope.chartObject = utils.gchart(data.benchmark.runs,
							"test");
				} ]);
