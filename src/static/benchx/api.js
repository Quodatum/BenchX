/*
 * API for BenchX, returns promises
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.api', [ 'ngResource','log.ex.uo' ])

.constant("apiRoot", "../../benchx/api/")

.factory('api', [ '$resource', 'apiRoot', function($resource, apiRoot) {
	return {

		state : function() {
			return $resource(apiRoot + 'state').get().$promise;
		},
		stateSave : function(data) {
			return $resource(apiRoot + 'state', {
				mode: "@mode",
				factor : "@factor",
				generator: "@generator",
			}).save(data).$promise;
		},
		xmlgen : function(factor) {
			return $resource(apiRoot + 'xmlgen', {
				factor : "@factor"
			}).save({
				factor : factor
			}).$promise;
		},

		thisenv : function() {
			return $resource(apiRoot + 'thisenv').get().$promise;
		},
		
		session : function() {
			return $resource(apiRoot + 'session');
		},
		
		library : function(format) {
			return $resource(apiRoot + 'library/:id', {
			    format:format,
				id : "@id"
			});
		},
		
		environment : function() {
			return $resource(apiRoot + 'environment/:id', {
				id : "@id"
			});
		},
		compare : function(id) {
			return $resource(apiRoot + 'library/:id/compare', {
				id : "@id"
				// expecting state and query
			});
		},
		suites : function() {
			return $resource(apiRoot + 'suite').query().$promise;
		},
		suite : function(suite) {
			return $resource(apiRoot + 'suite/:suite', {
				suite : "@suite"
			}).get({
				suite : suite
			}).$promise;
		},
		execute : function(data) {
			return $resource(apiRoot + 'execute').save(data).$promise;
		}
	};
} ]);
