Class {
	#name : #SLCounter,
	#superclass : #Object,
	#category : #'SpyLite-Scenario'
}

{ #category : #'as yet unclassified' }
SLCounter >> anAssignment [
	| a |
	a := 3.
	^ a
]

{ #category : #accessing }
SLCounter >> main [
	^ self one
]

{ #category : #'as yet unclassified' }
SLCounter >> methMix [
	| aBoolean number |
	aBoolean := 2 == 3.
	aBoolean
		ifTrue: [ number := 3 ]
		ifFalse: [ number := 5 ].
	number := number + 1.
	^ number
]

{ #category : #'as yet unclassified' }
SLCounter >> methWithArguments: aList [
	| selectedNumbers |
	selectedNumbers := OrderedCollection new.
	aList detect: [ :aNum | aNum odd ]
	ifFound: [ :aNum | 
		aNum > 10 ifTrue: [ 
			selectedNumbers add: aNum
		] ifFalse: [ 
			selectedNumbers add: aNum * 3
		]
	] ifNone: [  ].
	^ selectedNumbers 
]

{ #category : #'as yet unclassified' }
SLCounter >> methWithComposeBlocks [
	| list selectedNumbers |
	selectedNumbers := OrderedCollection new.
	list := { 1. 4. 6. 7. 8. 15. 17. 16 }.
	list select: [ :aNum | aNum odd ]
	thenDo: [ :aNum | 
		aNum > 10 ifTrue: [ 
			selectedNumbers add: aNum
		] ].
	^ selectedNumbers 
]

{ #category : #'as yet unclassified' }
SLCounter >> methWithCondition [
	^ 2 = 1
		ifTrue: [ 3 ]
		ifFalse: [ 4 ]
]

{ #category : #'accessing structure variables' }
SLCounter >> one [
	^ 1.
]
