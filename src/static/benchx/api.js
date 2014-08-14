/*
 * API for BenchX, returns promises
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.api', [ 'ngResource','log.ex.uo' ])

.constant("metaRoot", "../../benchx/meta/")
.factory('meta', [ '$resource', 'metaRoot', function($resource, metaRoot) {
	return {

		cvabar : function(name) {
			return $resource(metaRoot + 'cvabar/'+name).get().$promise;
		}
	};
}])

.constant("apiRoot", "../../benchx/api/")


.factory('api', [ '$resource', 'apiRoot', function($resource, apiRoot) {
	return {

		state : function() {
			return $resource(apiRoot + 'state').get().$promise;
		},
		stateSave : function(data) {
			return $resource(apiRoot + 'state', {
				mode: "@mode",
				factor : "@factor"
			}).save(data).$promise;
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
			return $resource(apiRoot + 'environment').get().$promise;

		},
		library : function() {
			return $resource(apiRoot + 'library/:id', {
				id : "@id"
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
