let $auction := doc("xmlgen/auction.xml") return
for $b in $auction//site/regions return count($b//item)

