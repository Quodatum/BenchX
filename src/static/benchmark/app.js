var App = angular.module(
		'benchapp',
		[ 'ngRoute', 'ngResource', 'ui.bootstrap',
				'services.httpRequestTracker' ])

.constant("apiRoot", "../../benchmark/")

.config([ '$routeProvider', function($routeProvider) {
	console.log("APP config");
	$routeProvider.when('/', {
		redirectTo : '/results'
	}).when('/results', {
		templateUrl : '/static/benchmark/templates/query.xml',
		controller : "queriesController"
	}).when('/about', {
		templateUrl : '/static/benchmark/templates/about.xml'
	}).when('/404', {
		templateUrl : '/static/benchmark/templates/404.xml',
		controller : "queriesController"
	}).otherwise({
		redirectTo : '/404'
	});
} ])

.controller(
		'rootController',
		[ '$rootScope', 'httpRequestTracker', 'api', 'queries',
				function($rootScope, httpRequestTracker, api, queries) {
					function updateStatus(data){
						console.log("update status:",data)
						$rootScope.state = data.state;
					};
					$rootScope.queries = [];

					$rootScope.queue = async.queue(function(index, callback) {
						console.log('start ' + index);
						$rootScope.execute(index).then(function(res) {
							// Dig into the responde to get the relevant data
							console.log('done ' + index, res);
							callback();
						});
					}, 1);

					// run query with index
					$rootScope.execute = function(index) {
						var q = $rootScope.queries[index];
						return queries.execute({
							name : q.name,
							mode : $rootScope.state.mode,
							size : $rootScope.state.size
						}).then(function(res) {
							// Dig into the responde to get the relevant data
							console.log("exe", res);
							$rootScope.queries[index].runs.unshift(res);
						})
					};
					$rootScope.executeAll = function() {
						angular.forEach($rootScope.queries, function(v, index) {
							$rootScope.queue.push(index)
						})
					};
					$rootScope.clearAll = function() {
						angular.forEach($rootScope.queries, function(v) {
							v.runs = [];
						})
					};
					$rootScope.toggleMode = function() {
						api.toggleMode().success(function(d){
							api.status().success(updateStatus);
						});
					};
					$rootScope.xmlgen = function() {
						api.xmlgen(0.3).success(function(d){
							api.status().success(updateStatus);
						});
					};
					console.log("rooT");
					
					api.status().success(updateStatus);
					$rootScope.hasPendingRequests = function() {
						return httpRequestTracker.hasPendingRequests();
					};
				} ])

.controller(
		'queriesController',
		[ "$scope", "$rootScope", "queries",
				function($scope, $rootScope, queries) {
					console.log("queries");
					queries.getData().then(function(data) {
						// Dig into the responde to get the relevant data
						console.log("queries", data);
						$rootScope.queries = data;
					});
				} ])

.factory('api', [ '$http', 'apiRoot', function($http, apiRoot) {
	return {

		status : function() {
			return $http({
				method : 'GET',
				url : apiRoot + 'status'
			});
		},
		xmlgen:function(factor) {
			return $http({
				method : 'POST',
				url : apiRoot + 'xmlgen',
				params:{factor:factor}
			});
	},
	toggleMode:function() {
		return $http({
			method : 'POST',
			url : apiRoot + 'manage'
		});
	}
	}
}])

.factory('queries', [ '$http', '$q', 'apiRoot', function($http, $q, apiRoot) {
	var q = [];
	return {

		getData : function() {
			console.log("GET");
			var defer = $q.defer();
			$http({
				method : 'GET',
				url : apiRoot + 'queries'
			}).success(function(data) {
				q=data.queries;
				defer.resolve(q);
			});

			return defer.promise;
		},
		execute:function(data){
			var defer = $q.defer();
			$http({
				url : apiRoot + 'execute',
				method : 'POST',
				data : data
			}).success(function(data) {
				defer.resolve(data);
			});

			return defer.promise;
		}
	}
} ]);
