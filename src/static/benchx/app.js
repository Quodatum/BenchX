/*
 * BenchX angular application
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular
		.module(
				'BenchX',
				[ 'ngRoute', 'ngTouch', 'ui.bootstrap', 'cfp.hotkeys',
						'googlechart', 'angularCharts', 'dialog', 'ngStorage',
						'angularMoment', 'BenchX.api', 'BenchX.services',
						'services.httpRequestTracker' ])

		.config([ '$routeProvider', function($routeProvider) {
			$routeProvider.when('/', {
				redirectTo : '/suite'
			}).when('/suite/:suit/session', {
				templateUrl : '/static/benchx/templates/session.xml',
				controller : "SessionController"
			}).when('/suite/:suit/library', {
				templateUrl : '/static/benchx/templates/library.xml',
				controller : "LibraryController",
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
							$rootScope.logmsg = "Welcome to BenchX v0.5.2";
							$rootScope.suites = [ "xmark", "apb" ];
							$rootScope.activesuite = "xmark";
							$rootScope.meta = {
								title : ""
							};
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
												case "state":
													$rootScope.logmsg = 'Starting set state';
													promise = $rootScope
															.setState(task.data);
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
															$rootScope.logmsg = 'completed '
																	+ task.cmd;
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
						'utils',

						function($rootScope, api, utils) {
							function updateStatus(data) {
								console.log("update status:", data);
								$rootScope.state = data.state;
							}

							$rootScope.$watch("session", function() {
								// to kick charts to update
								$rootScope.$broadcast("session");
							}, true);

							// run query with index
							$rootScope.execute = function(index) {
								var q = $rootScope.session.queries[index];
								return api
										.execute({
											suite : $rootScope.activesuite,
											name : q.name,
											mode : $rootScope.state.mode,
											size : $rootScope.state.size
										})
										.then(
												function(res) {
													$rootScope.session.queries[index].runs
															.push(res.run);
													$rootScope
															.$broadcast("session");
												},
												function(reason) {
													alert("Execution error"
															+ reason.data);
												});
							};

							$rootScope.saveAs = function() {
								var csv = utils.csv($rootScope.session,
										$rootScope.activesuite);
								saveAs(csv, "results.csv");
							};

							$rootScope.setState = function(data) {
								return api.stateSave(data).then(
										function(d) {
											api.state().then(updateStatus);
										},
										function(reason) {
											alert("Failed to set state\n"
													+ reason.data);
										});
							};
							api.suite($rootScope.activesuite).then(
									function(data) {
										$rootScope.session = data;

									});
							api.state().then(updateStatus);

						} ])

		.controller(
				'SessionController',
				[
						"$scope",
						"$rootScope",
						'$routeParams',
						"$location",
						"$dialog",
						"api",
						function($scope, $rootScope, $routeParams, $location,
								$dialog, api) {
							$rootScope.setTitle("Session: "
									+ $rootScope.activesuite);
							$scope.store = {
								title : ""
							};

							$scope.setView = function(v) {
								$scope.view = v;
								$location.search("view", v);
							};
							$scope
									.setView($routeParams.view ? $routeParams.view
											: "grid");

							$scope.clearAll = function() {
								var msg = "Remove timing data for runs in the current session?";

								$dialog
										.messageBox(
												"clear all",
												msg,
												[],
												function(result) {
													if (result === 'OK') {
														angular
																.forEach(
																		$rootScope.session.queries,
																		function(
																				v) {
																			v.runs = [];
																		})
													} else {
														// failed...
													}
												});
							};
							$scope.save = function() {
								var d = new api.library();
								d.save($scope.meta).$promise.then(function(a) {
									$rootScope.logmsg = "Saved to library.";
								}, function(e) {
									alert("FAILED: " + e.data);
								});
							};
						} ])
		.controller(
				'ScheduleController',
				[
						"$scope",
						"$rootScope",
						"api",
						"$localStorage",
						function($scope, $rootScope, api, $localStorage) {
							console.log("ScheduleController");
							function makerun(mode, factor) {
								var tasks = [ {
									cmd : "state",
									data : {
										mode : mode,
										factor : factor
									}
								} ];
								angular.forEach($rootScope.session.queries,
										function(v, index) {
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
									allmodes : true,
									doIncr : false,
									incr : 0.25,
									repeat : 1,
									maxfactor : 1
								}
							});

							$scope.executeAll = function() {
								var settings = $scope.$storage.settings;

								for (var i = 0; i < settings.repeat; i++) {
									var f = settings.factor;
									do {
										var m = settings.mode;
										var tasks = makerun(m, f);
										$rootScope.queue.push(tasks);
										if (settings.allmodes) {
											m = (m == "F") ? "D" : "F";
											var tasks = makerun(m, f);
											$rootScope.queue.push(tasks);
										}
										;
										f += settings.incr;
									} while (settings.doIncr
											&& f <= settings.maxfactor);
								}
								;
								$scope.setView("graph");
							};
							$scope.setNow = function() {
								var settings = $scope.$storage.settings;
								$rootScope.queue.push({
									cmd : "state",
									data : {
										mode : settings.mode,
										factor : settings.factor
									}
								});

							};
						} ])
		.controller('envController',
				[ "$scope", "data", function($scope, data) {
					$scope.setTitle("Environment");
					$scope.environment = data;
				} ])
		.controller('SuitesController',
				[ "$scope", "data", function($scope, data) {
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
						function($scope, $rootScope, data, $routeParams,
								$location, utils) {
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
							$scope.chartObject = utils.gchart(
									data.benchmark.runs, "test");
						} ])

		.controller(
				"ChartController",
				[
						'$scope',
						'$rootScope',
						'$window',
						'utils',
						function($scope, $rootScope, $window, utils) {
							$scope.setTitle("Graph");
							function genChart() {
								return utils.gchart($rootScope.session.queries,
										'BenchX: ' + $rootScope.suite + " "
												+ $rootScope.meta.title);
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
				} ]);
