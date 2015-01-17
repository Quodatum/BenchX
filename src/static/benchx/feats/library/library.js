/*
 * library handler
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.library', [ 'ngResource','ngRoute','BenchX.api' ])

.config([ '$routeProvider', function($routeProvider) {
	$routeProvider.when('/library', {
		templateUrl : '/static/benchx/feats/library/library.xhtml',
		controller : "LibraryController",
		resolve : {
			data : function(api) {
				return api.library().query().$promise;
			}
		}

	}).when('/library/item/:id', {
		templateUrl : '/static/benchx/feats/library/record.xml',
		controller : "RecordController",
		resolve : {
			data : function(api, $route) {
				var id = $route.current.params.id;
				return api.library().get({
					id : id
				}).$promise;
			}
		}

	}).when('/library/item/:id/compare', {
		templateUrl : '/static/benchx/feats/library/compare.xml',
		controller : "CompareController",
		resolve : {
			data : function(api, $route) {
				var id = $route.current.params.id;
				var q="q01.xq";var state="F0";
				console.log("LOC",q);
				return api.compare(id).get({
					id : id,
					query:q,
					state:state
				}).$promise;
			}
		}

	}).when('/environment', {
		templateUrl : '/static/benchx/feats/library/env.xml',
		controller : "EnvController",
		resolve : {
			data : function(api) {
				return api.environment().query().$promise;
			}
		}
	})
	;
} ])

.controller(
		'LibraryController',
		[ "$scope", "$rootScope", "data", "$log",
				function($scope, $rootScope, data, $log) {
					$scope.setTitle("Library");
					$scope.docs = data;
					$scope.libzip = function() {
						alert("TODO");
					};
				} ])

.controller(
		'CompareController',
		[ "$scope", "$rootScope", "data", "$log",
				function($scope, $rootScope, data, $log) {
					$scope.setTitle("Compare");
					$scope.docs = data;
					
				} ])
				
.controller(
		'EnvController',
		[ "$scope", "$rootScope","data",  "$log",
				function($scope, $rootScope,data, $log) {
					$scope.setTitle("Environments");
					$scope.environments=data;
					console.log("ENVS",data);
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
				"api",
				"$dialog",
				function($scope, $rootScope, data, $routeParams, $location,
						utils,api,$dialog) {
					$scope.setTitle("Record");
					$scope.benchmark = data.benchmark;
					console.log("benchmark: ",$scope.benchmark);
					//@TODO Extract names of factor
					$scope.data={
						states: _.groupBy(data.benchmark.runs,function(run){return run.mode + run.factor;}),
						queries: _.groupBy(data.benchmark.runs,function(run){return run.name;})
					};
					
					$scope.keys=function(obj){
						return _.map(obj,function(v,key){return key;})
					};
					$scope.getRuns=function(state,query){
						return _.filter(data.benchmark.runs,function(run){
									var r= (run.name==query) && (state==run.mode + run.factor);
								//	console.log("**",run.name,query,run.mode,state);
									return r;
									});
						};
						
					$scope.setView = function(v) {
						$scope.view = v;
						$location.search("view", v);
					};

					$scope.drop = function() {
							var id = $scope.benchmark.id;
							$dialog.messageBox("Delete from Library?", "Delete: "+id, [],
										function(result) {
											if (result === 'OK') {
												var d = new api.library();
												d.delete({id:id}).$promise.then(function(a) {
												$location.path("/library");
												$rootScope.logmsg = "library data deleted.";
											}, function(e) {
												alert("FAILED: " + e.data);
											});	
											}
										});
					};
					
					function genChart(){
						var cols = [ {
							id : "t",
							label : "Query",
							type : "string"
						} ];
						angular.forEach($scope.data.states, function(a, r) {
							cols.push( {
							id : r,
							label : r,
							type : "number"
							});
						});
						 
						var rows=[];
						
						function row(q,index){
							var d=[{v:q}];
							angular.forEach($scope.data.states, function(a,state) {
								var runs=$scope.getRuns(state,q);
								d.push({
									v : runs[index].runtime
								});
							});
							return d;
						};
						for(i=0;i<3;i++){
						angular.forEach($scope.data.queries, function(a, q) {
							var d = row(q,i);
							rows.push({
								c : d
							});
						});
						};
						
						var options={
								title:'BenchX: library',
								 vAxis: {title: 'Time (sec)'},
								 hAxis: {title: 'Query'}
								 };
								 
						return {
								type : "ColumnChart",
								options : options,
								data : {
									"cols" : cols,
									"rows" : rows
								}
							};
					};
					$scope.chartObject=genChart();
					$scope.setView($routeParams.view ? $routeParams.view: "grid");
				} ]);
