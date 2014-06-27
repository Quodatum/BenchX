/*
 * BenchX angular services
 * filters and factories
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.services', [  ])
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
		gchart : function(session, title) {
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
				options : {
					'title' : title
				},
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
			})
		}
	};
})
.directive('scrollTo', function ($location, $anchorScroll) {
  return function(scope, element, attrs) {

    element.bind('click', function(event) {
        event.stopPropagation();
        var off = scope.$on('$locationChangeStart', function(ev) {
            off();
            ev.preventDefault();
        });
        var location = attrs.scrollTo;
        $location.hash(location);
        $anchorScroll();
    });
};
})
/*
.config(function($provide) {
	// @see https://coderwall.com/p/_zporq
	  $provide.decorator('$log',"rootScope", function($delegate, $sniffer) {
	        var _log = $delegate.log; //Saving the original behavior

	        $delegate.log = function(message) {
	        	$rootScope.logmsg=message;
	        };
	        $delegate.error = function(message) {
	            alert(message);
	        }

	        return $delegate;
	    });
	})
	*/
;
