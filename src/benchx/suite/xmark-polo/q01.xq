let $auction := collection("benchx-db") return
for $b in $auction/site/people/person[@id = "person0"] return $b/name/text()

