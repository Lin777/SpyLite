Extension { #name : #CompiledMethod }

{ #category : #'*SpyLite' }
CompiledMethod >> copyFor: aBehavior [
	| copy numberOfLiterals superRef |
	numberOfLiterals := self numLiterals.
	copy := self copy.
	superRef := (self literalAt: numberOfLiterals) copy.
	superRef value: aBehavior.
	copy literalAt: numberOfLiterals put: superRef.
	^ copy
]

{ #category : #'*SpyLite-testing' }
CompiledMethod >> hasMethodSpyAsLiteral [
	"True if one of my literals has a method spy"
	^ self literals anySatisfy: [ :l | (l isKindOf: SLMethod) ]
]

{ #category : #'*SpyLite-testing' }
CompiledMethod >> isSpy [
	^ (self objectAt: 2) isSpyMethod
]

{ #category : #'*SpyLite-testing' }
CompiledMethod >> isTemplateMethod [
	^ SLProfiler templateMethods anySatisfy: [ :cm | (self size = cm size) 
													and: [ (self initialPC to: self endPC) allSatisfy: [ :i | 
															(self at: i) = (cm at: i) ] ] ]
]

{ #category : #'*SpyLite' }
CompiledMethod >> methodSpy [
	self assert: [ self isSpy ].
	^ self objectAt: 2
]

{ #category : #'*SpyLite-testing' }
CompiledMethod >> numberOfLinesOfCode [
	(self propertyValueAt: #numberOfLinesOfCode)
			ifNil: [ self propertyValueAt: #numberOfLinesOfCode put: self source lineCount ].

	^ self propertyValueAt: #numberOfLinesOfCode 
]

{ #category : #'*SpyLite' }
CompiledMethod >> originalMethod [
	^ self methodSpy originalMethod
]

{ #category : #'*SpyLite' }
CompiledMethod >> replaceLiteral: anObject by: anotherObject [
	1 to: self numLiterals do: [ :i | 
		((self literalAt: i) = anObject)
			ifTrue: [ self literalAt: i put: anotherObject ]
	]
]

{ #category : #'*SpyLite' }
CompiledMethod >> replaceLiterals: associations [
	associations do: [:assoc | self replaceLiteral: assoc key by: assoc value ]
]
