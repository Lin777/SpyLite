Extension { #name : #Behavior }

{ #category : #'*SpyLite' }
Behavior >> classSpy [ 
	| spys |
	spys := self spys.
	spys ifEmpty: [ self error: 'no spy installed'. ^ self].
	^ self spys first classSpy
]

{ #category : #'*SpyLite' }
Behavior >> hasSpy [
	^ self methodDict values anySatisfy: [ :spy | spy isTemplateMethod ]
]

{ #category : #'*SpyLite' }
Behavior >> profiler [
	^ self classSpy profiler
]

{ #category : #'*SpyLite' }
Behavior >> removeSpys [
	(self == SLProfiler class) ifTrue: [ ^ self ].
	self isMeta ifFalse: [ self class removeSpys ].
	self methodDict associationsDo:[:assoc|
		 assoc value isSpy ifTrue:[
				self methodDict at: assoc key put: assoc value originalMethod.
			].
		].
]

{ #category : #'*SpyLite' }
Behavior >> spyFor: aSelector [
	| v |
	v := self methodDict at: aSelector.
	self assert: [ v isSpy ].
	^ v
]

{ #category : #'*SpyLite' }
Behavior >> spys [
	^ (self methodDict values select: [ :spy | spy isTemplateMethod ]) collect: #methodSpy
]
