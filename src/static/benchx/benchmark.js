/*
 * Manage Benchmark results
 * @author andy bunce
 * @copyright quodatum
 * @date 2014
 * @licence Apache 2
 */
angular.module('BenchX.benchmark', [])

.factory("benchmark", [  function() {
	var _data;  //the data
	
	return {
		set : function(data){
			_data=data;
			console.log("TODO BenchX.benchmark",data)
			return data;
			},
		
		get:function(){
			return _data;
			}
		
		
	};
} ]);
