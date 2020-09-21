Extension { #name : #SequenceableCollection }

{ #category : #'*SpyLite' }
SequenceableCollection >> combinationsWith: aCollection [ 
    ^ self flatCollect: [ :e |
        aCollection collect: [ :i |
            (Array with: e with: i) flattened
        ]    
     ]
]
