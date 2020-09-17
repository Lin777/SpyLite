Extension { #name : #Collection }

{ #category : #'*SpyLite' }
Collection >> containsCleanedBlocks [
	^ self allSatisfy: [ :each | |result|
		result := true.
		each isBlock ifTrue: [ result := each isClean ].
		result		
	]
]
