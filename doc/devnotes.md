# dev guide

rootcontroler sets session. session is indexed by query index
    $rootScope.session.queries[index].runs.push(res.run);
    
graph use $rootscope.session

##session
$rootScope.session.queries.runs[]
set by $rootScope.session = api.suite(name) in rootController

##results
Manages the session run times.

##$rootScope
.suites[] is set to array as below

{   name:"xmark",
    href:"#/suite/xmark",
    describe:"to doxmark",
    session:"#/suite/xmark/session",
    library: "#/suite/xmark/library",
    queries: ["q01.xq", "q02.xq", "q03.xq", 17 more...]
}

.session[]
{   env:{},
    times:[]
 }
.activesuite 
name of active suite

{
  "run": {
    "runtime": 116,
    "status": "",
    "name": "q02.xq",
    "mode": "D",
    "factor": "0.25",
    "created": "2014-05-21T21:25:28.793+01:00",
    "src:"?library id",
    serverid?
  }
}
Key is mode+factor+serverid


## difference
 ((V2 - V1) / |V1|) * 100

## logging
