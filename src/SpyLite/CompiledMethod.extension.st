Extension { #name : #CompiledMethod }

{ #category : #'*SpyLite-testing' }
CompiledMethod >> hasMethodSpyAsLiteral [
	"True if one of my literals has a method spy"
	^ self literals anySatisfy: [ :l | (l isKindOf: SLMethod) ]
]

{ #category : #'*SpyLite-testing' }
CompiledMethod >> isTemplateMethod [
	^ SLProfiler templateMethods anySatisfy: [ :cm | (self size = cm size) 
													and: [ (self initialPC to: self endPC) allSatisfy: [ :i | 
															(self at: i) = (cm at: i) ] ] ]
]
