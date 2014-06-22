# dev guide

rootcontroler sets session. session is indexed by query index
    $rootScope.session.queries[index].runs.push(res.run);
    
graph use $rootscope.session

#suites
In rootControler $rootScope.suites is set to array as below

name:"xmark"
href:"#/suite/xmark"
describe:"to doxmark"
session:"#/suite/xmark/session"
library: "#/suite/xmark/library"
queries: ["q01.xq", "q02.xq", "q03.xq", 17 more...]


# generate xquery documentation
\workspace\benchmark.xq\src>xquerydoc -x benchx -o static/doc/server

