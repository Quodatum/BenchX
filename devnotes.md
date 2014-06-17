# dev guide

rootcontroler sets session. session is indexed by query index
    $rootScope.session.queries[index].runs.push(res.run);
    
graph use $rootscope.session

suite

# generate xquery documentation
\workspace\benchmark.xq\src>xquerydoc -x benchx -o static/doc/server

