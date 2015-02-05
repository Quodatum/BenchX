let $auction := collection("benchx-db") return
for $b in $auction//site/regions return count($b//item)

