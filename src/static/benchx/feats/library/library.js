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
		[ "$scope", "$rootScope","$routeParams","$location", "data", "$log",
				function($scope, $rootScope,$routeParams,$location, data, $log) {
					$scope.setTitle("Compare");
					$scope.compare = data;
					$scope.route=$routeParams; //id,query,state
				} ])
				
.controller(
		'EnvController',
		[ "$scope", "$rootScope","$routeParams","$location","data",  "$log",
				function($scope, $rootScope,$routeParams,$location,data, $log) {
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
				"benchmark",
				function($scope, $rootScope, data, $routeParams, $location,
						utils,api,$dialog,benchmark) {
					var state=function(run){return run.mode + run.factor;};

					$scope.setTitle("Record");
					$scope.formData={average:$location.search().avg,
							         relative:$location.search().rel};
					var b=benchmark.set(data.benchmark);
					$scope.benchmark = data.benchmark;
					if($scope.formData.average){
						console.log("average");
						var a=_.groupBy($scope.benchmark.runs,function(run){return run.name+run.mode + run.factor;});
					};
					if($scope.formData.relative){
						console.log("relative");
					};
					console.log("benchmark: ",$scope.benchmark);
					//@TODO Extract names of factor
					$scope.data={
						//{state:[{run}]}
						states: _.groupBy(data.benchmark.runs,state),
						//{query:[{run}]
						queries: _.groupBy(data.benchmark.runs,function(run){return run.name;}),
						// run with max time
						max: _.max(data.benchmark.runs,function(run){return run.runtime;})
					};
					
					// array of key names from groupby object
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
					
					$scope.onformData=function(){
						$location.search("avg",$scope.formData.average);
						$location.search("rel",$scope.formData.relative);
						//console.log("formData.average",$scope.formData.average);
					};
					
					// json data for google bar chart
					function genChart(){
						var colors=["#3366cc","#dc3912","#ff9900","#109618","#990099","#0099c6","#dd4477","#66aa00","#b82e2e","#316395","#994499","#22aa99","#aaaa11","#6633cc","#e67300","#8b0707","#651067","#329262","#5574a6","#3b3eac","#b77322","#16d620","#b91383","#f4359e","#9c5935","#a9c413","#2a778d","#668d1c","#bea413","#0c5922","#743411"];
						var states=_.map($scope.data.states,function(runs,state){return state;});
					
						var session=_.map($scope.data.queries,
								function(v,key){return {
												"name":key,
												"runs":_.sortBy(v,state)
												}
								;});
						var c=_.map(session[0].runs,function(run,index){
									var state=run.mode + run.factor;
									var pos=states.indexOf(state);
									//console.log("££",state,pos);
									return colors[pos];
						});
						c=_.flatten(c);
						var options={
								 title:'BenchX: ' + $scope.benchmark.suite + " " + $scope.benchmark.meta.description,
								 vAxis: {title: 'Time (sec)'}
								 ,hAxis: {title: 'Query'}
								// ,legend: 'none'
								 ,colors: c
								 };
						return utils.gchart(session,options);
								 
					};
					
					$scope.chartObject=genChart();
					$scope.setView($routeParams.view ? $routeParams.view: "grid");
				} ]);
