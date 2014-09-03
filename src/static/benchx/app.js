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
						'ngLogging', 'angularMoment', 'googlechart',
						'log.ex.uo', 'angularCharts', 'dialog', 'ngStorage',
						'BenchX.api', 'BenchX.services', 'BenchX.results',
						'quodatum.cva', 'BenchX.library',
						'services.httpRequestTracker' ])

		.config(
				[
						'$routeProvider',
						"$injector",
						function($routeProvider, $injector) {
							$routeProvider
									.when('/', {
										redirectTo : '/suite'

									})
									.when(
											'/suite/:suite/session',
											{
												templateUrl : '/static/benchx/templates/session.xml',
												controller : "SessionController",
												resolve : {
													data : function(results,
															$route) {
														return results
																.promise($route.current.params.suite);
													}
												}
											})
									.when(
											'/suite/:suite/library',
											{
												templateUrl : '/static/benchx/templates/library.xhtml',
												controller : "LibraryController",
												/*
												 * resolve:
												 * $injector.get('LibraryResolve')
												 */
												resolve : {
													data : function(api, $route) {
														return api
																.suite($route.current.params.suite);
													}

												}
											})
									.when(
											'/environment',
											{
												templateUrl : '/static/benchx/templates/environment.xhtml',
												controller : "envController",
												resolve : {
													data : function(api) {
														return api
																.environment();
													}
												}

											})
									.when(
											'/about',
											{
												templateUrl : '/static/benchx/templates/about.xhtml'

											})
									.when(
											'/log',
											{
												templateUrl : '/static/benchx/templates/log.xhtml'

											})
									.when(
											'/suite',
											{
												templateUrl : '/static/benchx/templates/suites.xml',
												controller : "SuitesController",
												resolve : {
													data : function(api) {
														return api.suites();
													}
												}

											})
									.when(
											'/suite/:id',
											{
												templateUrl : '/static/benchx/templates/suite.xml',
												controller : "SuiteController",
												resolve : {
													data : function(api, $route) {
														return api
																.suite($route.current.params.id);
													}
												}
											})
									.when(
											'/doc/:view',
											{
												templateUrl : '/static/benchx/templates/doc.xhtml',
												controller : "DocController"

											})
									.when(
											'/404',
											{
												templateUrl : '/static/benchx/templates/404.xhtml'
											}).otherwise({
										redirectTo : '/404'
									});
						} ])

		.config([ 'logExProvider', function(logExProvider) {
			logExProvider.enableLogging(true);
		} ])

		// .config([ 'Logging', function(Logging) {
		// Logging.enabled=true;
		// } ])
		.run(
				[
						'$rootScope',
						'$window',
						'hotkeys',
						'$log',
						'Logging',
						"$localStorage",
						'results',
						function($rootScope, $window, hotkeys, $log, Logging,$localStorage,results) {
							Logging.enabled = true;
							$rootScope.$storage = $localStorage.$default({
							    activesuite: "xmark"
							})
							$rootScope.setTitle = function(t) {
								$window.document.title = t;
							};
							$rootScope.results=results;
							$rootScope.setTitle("BenchX");
							$rootScope.logmsg = "Welcome to BenchX v0.6.0";
							console.log($rootScope.$storage.activesuite);
							$rootScope.activesuite = $rootScope.$storage.activesuite;
							$rootScope.meta = {
								title : ""
							};
							$rootScope.queue = async
									.queue(
											function(task, callback) {
												var promise;
												switch (task.cmd) {
												case "run":
													$log.info('Starting '
															+ task.data);
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
						'$log',
						'results',
						function($rootScope, api, utils, $log, results) {
							function updateStatus(data) {
								$log.log("update status:", data);
								$rootScope.state = data.state;
							}

							$rootScope.$watch("session", function() {
								// to kick charts to update
								$rootScope.$broadcast("session");
							}, true);

							// run query with index
							$rootScope.execute = function(index) {
								var q = results.data().queries[index];
								return api.execute({
									suite : $rootScope.activesuite,
									name : q.name,
									mode : $rootScope.state.mode,
									size : $rootScope.state.size
								}).then(function(res) {
									results.addRun(index, res.run);
									$rootScope.$broadcast("session");
								}, function(reason) {
									alert("Execution error" + reason.data);
								});
							};

							$rootScope.saveAs = function() {
								var csv = utils.csv(results.data(),
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
							api.suites().then(function(data) {
								$log.log("suites:", data);
								$rootScope.suites = data;
							});

							api.state().then(updateStatus);

						} ])

		.controller(
				'SessionController',
				[
						"$scope",
						'$routeParams',
						"$location",
						"$dialog",
						"api",
						"data",
						"results",
						function($scope, $routeParams, $location, $dialog, api,
								data, results) {
							console.log("SessionController", data);
							$scope.session = data;
							$scope.setTitle("Session: " + $scope.activesuite);
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
								$dialog.messageBox("clear all", msg, [],
										function(result) {
											if (result === 'OK') {
												results.clear();
											}
										});
							};
							$scope.save = function() {
								var d = new api.library();
								d.save($scope.meta).$promise.then(function(a) {
									$scope.logmsg = "Saved to library.";
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
						"$log",
						"taskqueue",
						"results",
						function($scope, $rootScope, api, $localStorage, $log,
								taskqueue, results) {
							$log.log("ScheduleController");
							function makerun(mode, factor) {
								var tasks = [ {
									cmd : "state",
									data : {
										mode : mode,
										factor : factor
									}
								} ];
								angular.forEach(results.data().queries,
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
				[ "$scope", "data", "meta", function($scope, data, meta) {
					$scope.setTitle("Suites");
					$scope.suites = data;
					meta.cvabar("crumb-bar").then(function(d) {
						console.log("CVA", d);
						$scope.bar = d;
						$scope.activesuite = "AWA$$";
					});
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
				"ChartController",
				[
						'$scope',
						'$rootScope',
						'$window',
						'utils',
						'results',
						function($scope, $rootScope, $window, utils, results) {
							$scope.setTitle("Graph");
							$scope.session = results.data();
							function genChart() {
								return utils.gchart($scope.session.queries,
										'BenchX: ' + $scope.session.name + " "
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
													$log
															.log('select event fired!');
												});
							};
							$scope.$on("session", function() {
								$scope.chartObject = genChart();
							});
							$scope.chartObject = genChart();
						} ])

		.controller(
				'DocController',
				[
						"$scope",
						"$routeParams",
						"$location",
						"$anchorScroll",
						"$log",
						function($scope, $routeParams, $location,
								$anchorScroll, $log) {
							$log.log("View:", $routeParams.view);
							var map = {
								"xqdoc" : '/doc/app/benchx/server/xqdoc',
								"wadl" : '/doc/app/benchx/server/wadl',
								"components" : '/doc/app/benchx/client/components',
								"templates" : '/doc/app/benchx/client/templates',
								"xqdoc2" : 'doc/server'
							};
							$scope.view = $routeParams.view;
							$scope.inc = map[$routeParams.view];
							$scope.setTitle("docs");
							$scope.scrollTo = function(id) {
								$log.log("DDDD", id);
								$location.hash(id);
								// call $anchorScroll()
								$anchorScroll();
							};
						} ])
						;
