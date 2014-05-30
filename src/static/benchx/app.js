/*
 * BenchX angular appliction
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular
		.module(
				'BenchX',
				[ 'ngRoute', 'ngTouch', 'ui.bootstrap', 'cfp.hotkeys',
					'googlechart', 'angularCharts', 'dialog','ngStorage',
					'angularMoment', 'BenchX.api',
					'services.httpRequestTracker' ])

		.config([ '$routeProvider', function($routeProvider) {
			$routeProvider.when('/', {
				redirectTo : '/suite'
			}).when('/session', {
				templateUrl : '/static/benchx/templates/session.xml',
				controller : "SessionController"
			}).when('/environment', {
				templateUrl : '/static/benchx/templates/environment.xml',
				controller : "envController",
				resolve : {
					data : function(api) {
						return api.environment();
					}
				}
			}).when('/about', {
				templateUrl : '/static/benchx/templates/about.xml'
			}).when('/library', {
				templateUrl : '/static/benchx/templates/library.xml',
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
			}).when('/suite', {
				templateUrl : '/static/benchx/templates/suites.xml',
				controller : "SuitesController",
				resolve : {
					data : function(api) {
						return api.suites();
					}
				}
			}).when('/suite/:id', {
				templateUrl : '/static/benchx/templates/suite.xml',
				controller : "SuiteController",
				resolve : {
					data : function(api, $route) {
						return api.suite($route.current.params.id);
					}
				}
			}).when('/xqdoc', {
				templateUrl : '/static/benchx/templates/xqdoc.xml'
			}).when('/wadl', {
				templateUrl : '/static/benchx/templates/wadl.xml',
				controller : "WadlController"
			}).when('/404', {
				templateUrl : '/static/benchx/templates/404.xml'
			}).otherwise({
				redirectTo : '/404'
			});
		} ])

		.run(
				[
						'$rootScope',
						'$window',
						'hotkeys',
						function($rootScope, $window, hotkeys) {
							$rootScope.setTitle = function(t) {
								$window.document.title = t;
							};
							$rootScope.setTitle("BenchX");
							$rootScope.logmsg = "Welcome to BenchX v0.4";
							$rootScope.suites = [ "xmark", "apb" ];
							$rootScope.suite = "xmark";
							$rootScope.queue = async
									.queue(
											function(task, callback) {
												var promise;
												switch (task.cmd) {
												case "run":
													$rootScope.logmsg = 'Starting '
															+ task.data;
													promise = $rootScope
															.execute(task.data);
													break;
												case "toggle":
													$rootScope.logmsg = 'Starting mode toggle';
													promise = $rootScope
															.toggleMode();
													break;
												case "xmlgen":
													$rootScope.logmsg = 'Requesting XML generation';
													promise = $rootScope
															.xmlgen(task.data);
													break;
												default:
													$rootScope.logmsg = 'Unknown command ignored: '
															+ task.cmd;
												}
												;
												promise
														.then(function(res) {
															// Dig into the
															// responde to get
															// the relevant data
															$rootScope.logmsg = 'End of '
																	+ task.data;
															callback();
														});
											}, 1);
							$rootScope.queue.drain = function() {
								$rootScope.logmsg = 'Idle';
							};
							hotkeys.add("T",
									"toggles mode between file and database",
									$rootScope.toggleMode);
							hotkeys.add("X", "run all queries",
									$rootScope.executeAll);
						} ])

		.controller(
				'rootController',
				[
						'$rootScope',
						'api',

						function($rootScope, api) {
							function updateStatus(data) {
								console.log("update status:", data);
								$rootScope.state = data.state;
							}

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
										function(reason) {
											alert("Execution error"
													+ reason.data);
										});
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
								return api.xmlgen(factor).then(
										function(d) {
											api.status().then(updateStatus);
										},
										function(reason) {
											alert("Failed to run xmlgen\n"
													+ reason.data);
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
						"api",
						function($scope, $rootScope, $routeParams, $location,
								$modal, $dialog, api) {
							$rootScope.setTitle("Session");
							$scope.repeat = 2;
							$scope.store={description:""};
							$scope.setView = function(v) {
								$scope.view = v;
								$location.search("view", v);
							};
							$scope
									.setView($routeParams.view ? $routeParams.view
											: "grid");

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
								var d = new api.library();
								d.save($scope.store).$promise.then(function(a) {
									$rootScope.logmsg = "Saved to library.";
								}, function(e) {
									alert("FAILED: "+e.data);
								});
							};
						} ])
		.controller(
				'ScheduleController',
				[
						"$scope",
						"$rootScope",
						"api",
						"$modal",
						"$dialog","$localStorage",
						function($scope, $rootScope, api, $modal, $dialog,$localStorage) {
							console.log("ScheduleController");
							function makerun() {
								var tasks = [];
								angular.forEach($rootScope.session, function(v,
										index) {
									tasks.push({
										cmd : "run",
										data : index
									});
								});
								return tasks;
							}
							;
							$scope.$storage = $localStorage.$default({
								settings : {
										mode : "F",
										factor : 0,
										allmodes:true,
										incr : 0.25,
										repeat : 1,
										maxfactor : 1
									}
							});

						

							$scope.executeAll = function() {
								var tasks = makerun();
								for (var i = 0; i < $scope.$storage.settings.repeat; i++) {

									$rootScope.queue.push(tasks);
									if($scope.$storage.settings.allmodes){
									$rootScope.queue.push({
										cmd : "toggle",
										data : 0
									});
									};
									$rootScope.queue.push(tasks);
								}
								;
								$scope.setView("graph");
							};
							$scope.xmlgen = function() {
								$modal.open({
									templateUrl : 'templates/xmlgen.xml',
									size : "sm"
								}).result.then(function(factor) {
									$rootScope.queue.push({
										cmd : "xmlgen",
										data : factor
									});
								});
							};
							$scope.go = function() {
								alert("go: " + $scope.$storage.settings.repeat);
							};
						} ])
		.controller('envController',
				[ "$scope", "data", function($scope, data) {
					$scope.setTitle("Environment");
					$scope.environment = data.environment;
				} ])
		.controller('SuitesController',
				[ "$scope", "data", function($scope, data) {
					$scope.setTitle("Suites");
					console.log(data);
					$scope.suites = data;
				} ])
		.controller('SuiteController',
				[ "$scope", "data", function($scope, data) {
					$scope.setTitle("Suite");
					console.log(data);
					$scope.suite = data;
				} ])
		.controller(
				'LibraryController',
				[ "$scope", "$rootScope", "data",
						function($scope, $rootScope, data) {
							$scope.setTitle("Library");
							$scope.docs = data;
							$scope.swipe = function() {
								alert("TODO swipe");
							};
							$scope.libzip=function(){
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
						function($scope, $rootScope, data, $routeParams,
								$location) {
							$scope.setTitle("Record");
							$scope.record = data;
							$scope.setView = function(v) {
								$scope.view = v;
								$location.search("view", v);
							};
							$scope
									.setView($routeParams.view ? $routeParams.view
											: "grid");
							$scope.drop = function() {
								alert("TODO");
								var id=$scope.record.benchmark.id;
								$scope.record.$delete({id : id,
									password:"AAA"}) 
								.then(function(a){alert("A");},function(a){alert("B");});	
							};
							$scope.data = {
								"series" : [ "Sales", "Income", "Expense" ],
								"data" : [ {
									"x" : "Computers",
									"y" : [ 54, 0, 879 ],
									"tooltip" : "This is a tooltip"
								} ]
							};
						} ])

		.controller(
				"ChartController",
				[
						'$scope',
						'$rootScope',
						'$window',
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
													label : v.mode + ":"
															+ v.factor,
													type : "number"
												});
											});
									var rows = [];
									angular.forEach($rootScope.session,
											function(q, i) {
												var d = [ {
													v : q.name
												} ];
												angular.forEach(q.runs,
														function(r, i2) {
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
								$window.google.visualization.events
										.addListener(
												chartWrapper,
												'select',
												function() {
													console
															.log('select event fired!');
												});
							};
							$scope.$on("session", function() {
								$scope.chartObject = genChart();
							});
							$scope.chartObject = genChart();
						} ])

		.controller('WadlController',
				[ "$scope", "$rootScope", function($scope) {
					$scope.setTitle("WADL");
					$scope.run = function(path) {
						alert("TODO run:" + path);
					};
				} ])

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
		.filter('factorBytes', function() {
			return function(x) {
				return (0.027 + 116.49 * x) * 1048576;
			};
		});
