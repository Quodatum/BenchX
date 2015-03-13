(:
 : benchmark from  http://lambda.uta.edu/HXQ/
 : generator is hxq
:)
<result>{                                                              
         for $x at $i in doc("C:\Users\andy\Desktop\dblp.xml")//inproceedings                  
                       where $x/author = 'Leonidas Fegaras'                                
                       return <paper>{ $i, $x/booktitle/text(),                            
                                      ':', $x/title/text()                                
                              }</paper>                                                    
         }</result> 