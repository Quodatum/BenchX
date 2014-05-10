var App = angular.module(
		'benchapp',
		[ 'ngRoute', 'ngResource', 'ui.bootstrap', 'cfp.hotkeys',
				'googlechart', 'services.httpRequestTracker' ])

.constant("apiRoot", "../../benchmark/api/")

.config([ '$routeProvider', function($routeProvider) {
	$routeProvider.when('/', {
		redirectTo : '/session'
	}).when('/session', {
		templateUrl : '/static/benchmark/templates/session.xml',
		controller : "queriesController"
	}).when('/environment', {
		templateUrl : '/static/benchmark/templates/environment.xml',
		controller : "envController",
		resolve : {
			data : function(api) {
				return api.environment();
			}
		}
	}).when('/about', {
		templateUrl : '/static/benchmark/templates/about.xml'
	}).when('/graph', {
		templateUrl : '/static/benchmark/templates/graph.xml',
		controller : "GenericChartCtrl"
	}).when('/library', {
		templateUrl : '/static/benchmark/templates/library.xml'
	}).when('/xqdoc', {
		templateUrl : '/static/benchmark/templates/xqdoc.xml'
	}).when('/404', {
		templateUrl : '/static/benchmark/templates/404.xml'
	}).otherwise({
		redirectTo : '/404'
	});
} ])

.run([ '$rootScope', 'queries', function($rootScope, queries) {

	$rootScope.logmsg = "Welcome to Benchmark";
	$rootScope.suite = "xmark";
	
	$rootScope.queue = async.queue(function(task, callback) {
		var promise;
		switch (task.cmd) {
		case "run":
			$rootScope.logmsg = 'Starting ' + task.data;
			promise = $rootScope.execute(task.data);
			break;
		case "toggle":
			$rootScope.logmsg = 'Starting mode toggle';
			promise = $rootScope.toggleMode();
			break;
		default:
			$rootScope.logmsg = 'Unknown command ignored: ' + task.cmd;
		}
		;
		promise.then(function(res) {
			// Dig into the responde to get the relevant data
			$rootScope.logmsg = 'End of ' + task.data;
			callback();
		});
	}, 1);
	$rootScope.queue.drain=function(){
		$rootScope.logmsg = 'Idle';
	};
} ])

.controller(
		'rootController',
		[
				'$rootScope',
				'api',
				'queries',
				'$modal',
				function($rootScope, api, queries, $modal) {
					function updateStatus(data) {
						console.log("update status:", data);
						$rootScope.state = data.state;
					}
					;
					queries.getData().then(function(data) {
						$rootScope.queries = data;
					});
					// run query with index
					$rootScope.execute = function(index) {
						var q = $rootScope.queries[index];
						return queries.execute({
							name : q.name,
							mode : $rootScope.state.mode,
							size : $rootScope.state.size
						}).then(function(res) {
							$rootScope.queries[index].runs.unshift(res.run);
						})
					};
					$rootScope.executeAll = function() {
						var tasks = [];
						angular.forEach($rootScope.queries, function(v, index) {
							tasks.push({
								cmd : "run",
								data : index
							})
						});
						$rootScope.queue.push(tasks);
						$rootScope.queue.push({
							cmd : "toggle",
							data : 0
						});
						$rootScope.queue.push(tasks);
					};

					$rootScope.clearAll = function() {
						angular.forEach($rootScope.queries, function(v) {
							v.runs = [];
						})
					};
					$rootScope.toggleMode = function() {
						return api.toggleMode().then(function(d) {
							api.status().success(updateStatus);
						});
					};
					$rootScope.saveAs = function() {
						var heads = [ "suite", "query", "mode", "factor",
								"runtime" ];
						var txt = [ heads.join(",") ];
						angular.forEach($rootScope.queries, function(v) {
							angular.forEach(v.runs, function(r) {
								line = [ $rootScope.suite, v.name, r.mode,
										r.factor, r.runtime ];
								txt.push(line.join(","));
							});
						});
						var blob = new Blob([ txt.join("\n") ], {
							type : 'text/csv'
						});
						saveAs(blob, "results.csv");
					};

					$rootScope.xmlgen = function() {
						$modal.open({
							templateUrl : 'templates/xmlgen.xml',
							size : "sm"
						})

						.result.then(function(factor) {
							api.xmlgen(factor).success(function(d) {
								api.status().success(updateStatus);
							});
						});
					};

					api.status().success(updateStatus);

				} ])

.controller(
		'queriesController',
		[
				"$scope",
				"$rootScope",
				"queries",
				"hotkeys",
				function($scope, $rootScope, queries, hotkeys) {
					console.log("queries");
					hotkeys.add("T", "toggles mode between file and database",
							$rootScope.toggleMode);
					hotkeys.add("X", "run all queries", $rootScope.executeAll);

				} ])

.controller('envController', [ "$scope", "data", function($scope, data) {
	$scope.envs = data.env;
} ])

.controller(
		"GenericChartCtrl",
		function($scope, $rootScope, $window) {
			$scope.chartReady = function(chartWrapper) {
				$window.google.visualization.events.addListener(chartWrapper,
						'select', function() {
							console.log('select event fired!');
						});
			};

			var cols = [ {
				id : "t",
				label : "Query",
				type : "string"
			} ];
			angular.forEach($rootScope.queries[0].runs, function(v, index) {
				cols.push({
					id : "R" + index,
					label : "Mode: "+v.mode +", Factor:"+v.factor,
					type : "number"
				});
			});
			var rows = [];
			angular.forEach($rootScope.queries, function(q, i) {
				var d = [ {
					v : q.name
				} ];
				angular.forEach(q.runs, function(r, i2) {
					d.push({
						v : r.runtime
					})
				})
				rows.push({
					c : d
				});
			});
			$scope.chartObject = {
				type : "ColumnChart",
				options : {
					'title' : 'BaseX Benchmark: '+$rootScope.suite
				},
				data : {
					"cols" : cols,
					"rows" : rows
				}
			};
		})

.filter('readablizeBytes', function() {
	return function(bytes) {
		var s = [ 'bytes', 'kB', 'MB', 'GB', 'TB', 'PB' ];
		var e = Math.floor(Math.log(bytes) / Math.log(1024));
		return (bytes / Math.pow(1024, Math.floor(e))).toFixed(2) + " " + s[e];
	}
})
// convert xmark factor to bytes
.filter('factorBytes', function() {
	return function(input) {
		return (116.47106113642 * input - 0.00057972324877298) * 1000000;
	}
})

.factory('api',
		[ '$http', '$resource', 'apiRoot', function($http, $resource, apiRoot) {
			return {

				status : function() {
					return $http({
						method : 'GET',
						url : apiRoot + 'status'
					});
				},
				xmlgen : function(factor) {
					return $http({
						method : 'POST',
						url : apiRoot + 'xmlgen',
						params : {
							factor : factor
						}
					});
				},
				toggleMode : function() {
					return $resource(apiRoot + 'manage').save().$promise;
				},
				environment : function() {
					return $resource(apiRoot + 'environment').get().$promise;

				}
			}
		} ])

.factory('queries', [ '$http', '$q','$resource', 'apiRoot', 
                      function($http, $q, $resource, apiRoot) {
	var q = [];
	return {

		getData : function() {
			console.log("GET");
			return $resource(apiRoot + 'suite/xmark',{}).query().$promise;
		},
		execute : function(data) {
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
