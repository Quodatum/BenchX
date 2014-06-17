/*
 * API for BenchX, returns promises
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.api', [ 'ngResource' ])

.constant("apiRoot", "../../benchx/api/")

.factory('api', [ '$resource', 'apiRoot', function($resource, apiRoot) {
	/*
	var queue = async
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
			*/
	
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
