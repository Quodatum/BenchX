# benchmark.xq

A Web App packaging of the [XMark](http://www.xml-benchmark.org) benchmark for BaseX.
Version 7.8.2 of BaseX is required as the query timeout functionality of xquery:eval is used.



# Installation

1. copy the `xmark` folder to your `webapp` folder 
1. Start `basexhttp`
1. In browser navigate to `/xmark`

# Target file or database
The queries reference `doc("xmark/auction.xml")` so will run against the database `xmark`
if it exists otherwise they use the file system.

# xmlgen
Binaries are supplied for Windows and x86 Linux. For other platforms e.g. ARM you 
must recompile from the supplied `unix.c`. E.g.
`gcc -o xmlgen unix.c`

