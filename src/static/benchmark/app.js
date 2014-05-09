var App = angular.module(
		'benchapp',
		[ 'ngRoute', 'ngResource', 'ui.bootstrap', 'cfp.hotkeys','googlechart',
				'services.httpRequestTracker' ])

.constant("apiRoot", "../../benchmark/")

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
		controller :"GenericChartCtrl"
	}).when('/library', {
		templateUrl : '/static/benchmark/templates/library.xml'
	}).when('/xqdoc', {
		templateUrl : '/static/benchmark/templates/xqdoc.xml'
	}).when('/404', {
		templateUrl : '/static/benchmark/templates/404.xml',
		controller : "queriesController"
	}).otherwise({
		redirectTo : '/404'
	});
} ])

.run([ '$rootScope', 'queries', function($rootScope, queries) {

	$rootScope.logmsg = "Welcome to Benchmark";
	$rootScope.suite = "xmark";
	queries.getData().then(function(data) {
		$rootScope.queries = data;
	});
	$rootScope.queue = async.queue(function(task, callback) {
		var promise;
		switch (task.cmd) {
		case "run":
			$rootScope.logmsg = 'starting ' + task.data;
			promise = $rootScope.execute(task.data);
			break;
		case "toggle":
			$rootScope.logmsg = 'starting mode toggle';
			promise = $rootScope.toggleMode();
			break;
		default:
			$rootScope.logmsg = 'Unknown command ignored: '+task.cmd;
		}
		;
		promise.then(function(res) {
			// Dig into the responde to get the relevant data
			$rootScope.logmsg = 'end of ' + task.data;
			callback();
		});
	}, 1);
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
						var tasks=[];
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

.controller("GenericChartCtrl", function ($scope, $routeParams) {
    $scope.chartObject = {};

    $scope.onions = [
        {v: "Onions"},
        {v: 3},
    ];

    $scope.chartObject.data = {"cols": [
        {id: "t", label: "Topping", type: "string"},
        {id: "s", label: "Slices", type: "number"}
    ], "rows": [
        {c: [
            {v: "Mushrooms"},
            {v: 3},
        ]},
        {c: $scope.onions},
        {c: [
            {v: "Olives"},
            {v: 31}
        ]},
        {c: [
            {v: "Zucchini"},
            {v: 1},
        ]},
        {c: [
            {v: "Pepperoni"},
            {v: 2},
        ]}
    ]};


    // $routeParams.chartType == BarChart or PieChart or ColumnChart...
    $scope.chartObject.type = "BarChart";
    $scope.chartObject.options = {
        'title': 'How Much Pizza I Ate Last Night'
    }
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
				q = data.queries;
				defer.resolve(q);
			});

			return defer.promise;
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
