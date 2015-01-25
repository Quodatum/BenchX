/*
 * BenchX angular services
 * filters and factories
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
'use strict';
angular.module('BenchX.services', [ 'log.ex.uo' ])

// human size
.filter('readablizeBytes', function() {
	return function(bytes) {
		var s = [ 'bytes', 'kB', 'MB', 'GB', 'TB', 'PB' ];
		var e = Math.floor(Math.log(bytes) / Math.log(1024));
		return (bytes / Math.pow(1024, Math.floor(e))).toFixed(2) + " " + s[e];
	};
})

// convert xmark factor to bytes
.filter('factorBytes', function() {
	return function(x) {
		return (0.027 + 116.49 * x) * 1048576;
	};
})

.factory('utils', function() {
	return {
		// create google chart data structure
		// @param session [{name:query, runs:[]}]
		gchart : function(session, options) {
			if (!session)
				return;
			var cols = [ {
				id : "t",
				label : "Query",
				type : "string"
			} ];
			angular.forEach(session[0].runs, function(v, index) {
				cols.push({
					id : "R" + index,
					label : v.mode + ":" + v.factor,
					type : "number"
				});
			});
			// each row [query,times..]
			var rows = [];
			angular.forEach(session, function(q, i) {
				var d = [ {
					v : q.name
				} ];
				angular.forEach(q.runs, function(r, i2) {
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
				options : options,
				data : {
					"cols" : cols,
					"rows" : rows
				}
			};

		},
		// generate blob with csv
		csv : function(session, suite) {
			var heads = [ "suite", "query", "mode", "factor", "runtime" ];
			var txt = [ heads.join(",") ];
			angular.forEach(session.queries, function(v) {
				angular.forEach(v.runs, function(r) {
					line = [ suite, v.name, r.mode, r.factor, r.runtime ];
					txt.push(line.join(","));
				});
			});
			return new Blob([ txt.join("\n") ], {
				type : 'text/csv'
			});
		}
	};
})

.factory('taskqueue', ["$rootScope","$log", function($rootScope,$log) {
	console.log("taskq");
	var c = new Date();
	var q = async.queue(function(task, callback) {
		var promise;
		switch (task.cmd) {
		case "run":
			$log.info('Starting ' + task.data);
			$rootScope.logmsg = 'Starting ' + task.data;
			promise = $rootScope.execute(task.data);
			break;
		case "state":
			$rootScope.logmsg = 'Setting state: '+task.data.mode+task.data.factor;
			promise = $rootScope.setState(task.data);
			break;

		default:
			$rootScope.logmsg = 'Unknown command ignored: ' + task.cmd;
		}
		;
		promise.then(function(res) {
			// Dig into the
			// responde to get
			// the relevant data
			$rootScope.logmsg = 'completed ' + task.cmd;
			callback();
		});
	}, 1);
	q.drain = function() {
		$rootScope.logmsg = 'Idle';
	};
	return {
		"created" : c,
		"q" : q
	};
} ])

// http://www.bennadel.com/blog/2542-logging-client-side-errors-with-angularjs-and-stacktrace-js.htm
// The "stacktrace" library that we included in the Scripts
// is now in the Global scope; but, we don't want to reference
// global objects inside the AngularJS components - that's
// not how AngularJS rolls; as such, we want to wrap the
// stacktrace feature in a proper AngularJS service that
// formally exposes the print method.
.factory("stacktraceService", function() {

	// "printStackTrace" is a global object.
	return ({
		print : printStackTrace
	});

})
// -------------------------------------------------- //
// -------------------------------------------------- //

// By default, AngularJS will catch errors and log them to
// the Console. We want to keep that behavior; however, we
// want to intercept it so that we can also log the errors
// to the server for later analysis.
.provider("$exceptionHandler", {
	$get : function(errorLogService) {

		return (errorLogService);

	}
})
// -------------------------------------------------- //
// -------------------------------------------------- //

// The error log service is our wrapper around the core error
// handling ability of AngularJS. Notice that we pass off to
// the native "$log" method and then handle our additional
// server-side logging.
.factory("errorLogService", function($log, $window, stacktraceService) {

	// I log the given error to the remote server.
	function log(exception, cause) {

		// Pass off the error to the default error handler
		// on the AngualrJS logger. This will output the
		// error to the console (and let the application
		// keep running normally for the user).
		$log.error.apply($log, arguments);

		// Now, we need to try and log the error the server.
		// --
		// NOTE: In production, I have some debouncing
		// logic here to prevent the same client from
		// logging the same error over and over again! All
		// that would do is add noise to the log.
		try {

			var errorMessage = exception.toString();
			var stackTrace = stacktraceService.print({
				e : exception
			});

			// Log the JavaScript error to the server.
			// --
			// NOTE: In this demo, the POST URL doesn't
			// exists and will simply return a 404.

			var d = angular.toJson({
				errorUrl : $window.location.href,
				errorMessage : errorMessage,
				stackTrace : stackTrace,
				cause : (cause || "")
			});
			console.error("POST ERR", d);
			/*
			 * $.ajax({ type : "POST", url : "./javascript-errors", contentType :
			 * "application/json", data : d });
			 */
		} catch (loggingError) {

			// For Developers - log the log-failure.
			$log.warn("Error logging failed");
			$log.log(loggingError);

		}

	}

	// Return the logging function.
	return (log);

})

.constant("LibraryResolve", {
	data : [ 'api', function(api) {
		return api.library().query().$promise;
	} ]
})

/*
 * .config(function($provide) { //
 * 
 * @see https://coderwall.com/p/_zporq $provide.decorator('$log',"rootScope",
 *      function($delegate, $sniffer) { var _log = $delegate.log; //Saving the
 *      original behavior
 * 
 * $delegate.log = function(message) { $rootScope.logmsg=message; };
 * $delegate.error = function(message) { alert(message); }
 * 
 * return $delegate; }); })
 */

;
