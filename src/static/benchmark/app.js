var App = angular
		.module(
				'BenchX',
				[ 'ngRoute', 'ngResource','ngTouch',
				  'ui.bootstrap', 'cfp.hotkeys',
				'googlechart', 'services.httpRequestTracker', 'dialog' ])

		.constant("apiRoot", "../../benchmark/api/")

		.config([ '$routeProvider', function($routeProvider) {
			$routeProvider.when('/', {
				redirectTo : '/session'
			}).when('/session', {
				templateUrl : '/static/benchmark/templates/session.xml',
				controller : "SessionController"
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
			}).when('/library', {
				templateUrl : '/static/benchmark/templates/library.xml',
				controller : "LibraryController"
			}).when('/xqdoc', {
				templateUrl : '/static/benchmark/templates/xqdoc.xml'
			}).when('/wadl', {
				templateUrl : '/static/benchmark/templates/wadl.xml'
			}).when('/404', {
				templateUrl : '/static/benchmark/templates/404.xml'
			}).otherwise({
				redirectTo : '/404'
			});
		} ])

		.run([ '$rootScope','$window', function($rootScope,$window) {
			$rootScope.setTitle=function(t){$window.document.title = t;};
			$rootScope.setTitle("BenchX v0.2");
			$rootScope.logmsg = "Welcome to Benchmark";
			$rootScope.suites = [ "xmark", "apb" ];
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
				case "xmlgen":
					$rootScope.logmsg = 'Requesting XML generation';
					promise = $rootScope.xmlgen(task.data);
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
			$rootScope.queue.drain = function() {
				$rootScope.logmsg = 'Idle';
			};
		} ])

		.controller(
				'rootController',
				[
						'$rootScope',
						'api',
						'hotkeys',
						function($rootScope, api, hotkeys) {
							function updateStatus(data) {
								console.log("update status:", data);
								$rootScope.state = data.state;
							}
							hotkeys.add("T",
									"toggles mode between file and database",
									$rootScope.toggleMode);
							hotkeys.add("X", "run all queries",
									$rootScope.executeAll);

							$rootScope.$watch("session", function() {
								$rootScope.$broadcast("session");
							}, true);

							// run query with index
							$rootScope.execute = function(index) {
								var q = $rootScope.session[index];
								return api.execute({
									suite : $rootScope.suite,
									name : q.name,
									mode : $rootScope.state.mode,
									size : $rootScope.state.size
								}).then(
										function(res) {
											$rootScope.session[index].runs
													.push(res.run);
											$rootScope.$broadcast("session");
										},
										function(d){alert("Execution error");});
							};

							$rootScope.toggleMode = function() {
								return api.toggleMode().then(function(d) {
									api.status().then(updateStatus);
								});
							};
							$rootScope.saveAs = function() {
								var heads = [ "suite", "query", "mode",
										"factor", "runtime" ];
								var txt = [ heads.join(",") ];
								angular
										.forEach(
												$rootScope.session,
												function(v) {
													angular
															.forEach(
																	v.runs,
																	function(r) {
																		line = [
																				$rootScope.suite,
																				v.name,
																				r.mode,
																				r.factor,
																				r.runtime ];
																		txt
																				.push(line
																						.join(","));
																	});
												});
								var blob = new Blob([ txt.join("\n") ], {
									type : 'text/csv'
								});
								saveAs(blob, "results.csv");
							};

							$rootScope.xmlgen = function(factor) {
								return api.xmlgen(factor).then(function(d) {
									api.status().then(updateStatus);
								}, function(reason) {
									alert("Failed to run xmlgen\n" + reason.data);
								});
							};
							api.suite($rootScope.suite).then(function(data) {
								$rootScope.session = data;

							});
							api.status().then(updateStatus);

						} ])

		.controller(
				'SessionController',
				[
						"$scope",
						"$rootScope",
						'$routeParams',
						"$location",
						"$modal",
						"$dialog",
						function($scope, $rootScope, $routeParams, $location,
								$modal, $dialog) {
							$rootScope.setTitle("Session");
							$scope.repeat = 2;
							$scope.setView = function(v) {
								$scope.view = v;
								$location.search("view", v);
							};
							$scope
									.setView($routeParams.view ? $routeParams.view
											: "grid");

							$scope.executeAll = function() {
								var tasks = [];
								angular.forEach($rootScope.session, function(v,
										index) {
									tasks.push({
										cmd : "run",
										data : index
									});
								});
								$rootScope.queue.push(tasks);
								$rootScope.queue.push({
									cmd : "toggle",
									data : 0
								});
								$rootScope.queue.push(tasks);
								$scope.setView("graph");
							};
							$scope.xmlgen = function() {
								$modal.open({
									templateUrl : 'templates/xmlgen.xml',
									size : "sm"
								}).result.then(function(factor) {
									$rootScope.queue.push({cmd:"xmlgen",data:factor});
								});
							};
							$scope.clearAll = function() {
								var msg = "Remove timing data for runs in the current session?";

								$dialog.messageBox("clear all", msg, [],
										function(result) {
											if (result === 'OK') {
												angular.forEach(
														$rootScope.session,
														function(v) {
															v.runs = [];
														})
											} else {
												// failed...
											}
										});
							};
							$scope.save = function() {
								alert("hh");
							};
						} ])

		.controller('envController',
				[ "$scope", "data", function($scope, data) {
					$scope.setTitle("Environment");
					$scope.envs = data.env;
				} ])

		.controller('LibraryController', [ "$scope", "$rootScope",
		                                   function($scope,$rootScope) {
			$scope.setTitle("Library");
			$scope.swipe=function(){
				alert("TODO swipe");
			};
		} ])

		.controller(
				"ChartController",
				function($scope, $rootScope, $window) {
					$scope.setTitle("Graph");
					function genChart() {
						if ($rootScope.session) {
							var cols = [ {
								id : "t",
								label : "Query",
								type : "string"
							} ];
							angular.forEach($rootScope.session[0].runs,
									function(v, index) {
										cols.push({
											id : "R" + index,
											label : "Mode: " + v.mode
													+ ", Factor:" + v.factor,
											type : "number"
										});
									});
							var rows = [];
							angular.forEach($rootScope.session, function(q, i) {
								var d = [ {
									v : q.name
								} ];
								angular.forEach(q.runs, function(r, i2) {
									d.push({
										v : r.runtime
									});
								});
								rows.push({
									c : d
								});
							});
							return {
								type : "ColumnChart",
								options : {
									'title' : 'BaseX Benchmark: '
											+ $rootScope.suite
								},
								data : {
									"cols" : cols,
									"rows" : rows
								}
							};
						}
						;
					}
					;

					$scope.chartReady = function(chartWrapper) {
						// not working!!
						$window.google.visualization.events.addListener(
								chartWrapper, 'select', function() {
									console.log('select event fired!');
								});
					};
					$scope.$on("session", function() {
						$scope.chartObject = genChart();
					});
					$scope.chartObject = genChart();
				})

		.filter(
				'readablizeBytes',
				function() {
					return function(bytes) {
						var s = [ 'bytes', 'kB', 'MB', 'GB', 'TB', 'PB' ];
						var e = Math.floor(Math.log(bytes) / Math.log(1024));
						return (bytes / Math.pow(1024, Math.floor(e)))
								.toFixed(2)
								+ " " + s[e];
					};
				})
		// convert xmark factor to bytes
		.filter(
				'factorBytes',
				function() {
					return function(input) {
						return (116.47106113642 * input - 0.00057972324877298) * 1000000;
					};
				})

		.factory(
				'api',
				[
						'$http',
						'$resource',
						'apiRoot',
						function($http, $resource, apiRoot) {
							return {

								status : function() {
									return $resource(apiRoot + 'status').get().$promise;
								},
								xmlgen : function(factor) {
									return $resource(apiRoot + 'xmlgen', {
										factor : "@factor"
									}).save({
										factor : factor
									}).$promise;
								},
								toggleMode : function() {
									return $resource(apiRoot + 'manage').save().$promise;
								},
								environment : function() {
									return $resource(apiRoot + 'environment')
											.get().$promise;

								},
								suite : function(suite) {
									return $resource(apiRoot + 'suite/:suite',
											{
												suite : "@suite"
											}).query({
										suite : suite
									}).$promise;
								},
								execute : function(data) {
									return $resource(apiRoot + 'execute').save(
											data).$promise;
								}
							};
						} ]);
