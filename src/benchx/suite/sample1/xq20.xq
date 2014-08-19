for $ppl in doc('benchx-db/auction.xml')//people/person 
let $ic := $ppl/profile/@income
let $income :=  if($ic < 30000) then
                   "challenge"
                else if($ic >= 30000 and $ic < 100000) then
                   "standard"
                else if($ic >= 100000) then
                   "preferred"
                else
                   "na" 
group by $income
order by $income
return element { $income } { count($ppl) }