let $auction := doc("benchmark-db/auction.xml") return
for $b in $auction/site/people/person[@id = "person0"] return $b/name/text()

