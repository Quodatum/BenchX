let $auction := doc("benchx-db/auction.xml") return
for $b in $auction//site/regions return count($b//item)

