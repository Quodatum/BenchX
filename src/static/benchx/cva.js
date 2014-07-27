/*
 * crumbs,views,actions
 * @author andy bunce
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.cva', [ 'ngResource'])

.directive('cvaBar', function() {
  return {
      restrict: 'AE',
      replace: 'true',
      scope:false,
      templateUrl : 'templates/actionbar.xhtml'
      /*
     link: function(scope, elem, attrs) {
    	      elem.bind('mouseover', function() {
    	        elem.css('cursor', 'w-resize');
    	      });
    	    }
    	    */	  
  };
})
;