// busy indicator, analytics, error handling..
// part based on:
//https://github.com/angular-app/angular-app/blob/master/client/src/common/services/httpRequestTracker.js
angular.module('services.httpRequestTracker', [])

.run(
		[
				'$rootScope',
				'$window',
				'$location',
				'httpRequestTracker',
				function($rootScope, $window, $location, httpRequestTracker) {
					$rootScope.hasPendingRequests = function() {
						return httpRequestTracker.hasPendingRequests();
					};
					$rootScope.$on('$routeChangeError', function(event, cur,
							prev, rejection) {
						alert("routeChangeError @TODO");
					});
					// http://stackoverflow.com/questions/10713708/tracking-google-analytics-page-views-with-angular-js
					$rootScope.$on('$viewContentLoaded', function(event) {
						if ($window.ga) {
							$window.ga('send', 'pageview', {
								page : $location.path()
							});
						}
					});

				} ])

.factory('httpRequestTracker', [ '$http', function($http) {

	var httpRequestTracker = {};
	httpRequestTracker.hasPendingRequests = function() {
		return $http.pendingRequests.length > 0;
	};

	return httpRequestTracker;
} ]);