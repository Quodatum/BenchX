angular.module('BenchX.api', [ 'ngResource' ])

.constant("apiRoot", "../../benchmark/api/")

.factory('api', [ '$resource', 'apiRoot', function($resource, apiRoot) {
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
			return $resource(apiRoot + 'environment').get().$promise;

		},
		library : function() {
			return $resource(apiRoot + 'library/:id', {
				id : "@id"
			}).query().$promise;
		},
		record : function(id) {
			return $resource(apiRoot + 'library/:id', {
				id : "@id"
			}).get({
				id : id
			}).$promise;
		},
		suite : function(suite) {
			return $resource(apiRoot + 'suite/:suite', {
				suite : "@suite"
			}).query({
				suite : suite
			}).$promise;
		},
		execute : function(data) {
			return $resource(apiRoot + 'execute').save(data).$promise;
		}
	};
} ]);
