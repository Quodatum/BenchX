let $auction := doc("benchmark-db/auction.xml") return
for $b in $auction//site/regions return count($b//item)

