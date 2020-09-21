Extension { #name : #Object }

{ #category : #'*SpyLite' }
Object >> aSLProfilerCoverage [
	^ SLProfilerCoverage
]

{ #category : #'*SpyLite' }
Object >> aSTypeCollectorClass [
	^ SSTypeCollector
]

{ #category : #'*SpyLite' }
Object >> containUncleanedBlocks [ 
	| semaphore process result timeOut |
	result := self isUncleanedBlock.
	semaphore := Semaphore new.
	process := [ 
	[ 
	1 to: self class instSize do: 
		[ :i | result := result or: [(self instVarAt: i) isUncleanedBlock ] ].
	1 to: self basicSize do: 
		[ :i | result := result or: [ (self basicAt: i) isUncleanedBlock ] ].
	semaphore signal.
	] on: Error
	do: [ semaphore signal ]] fork.
	timeOut := semaphore waitTimeoutMSecs: 1000.
	timeOut ifTrue: [ 
		process terminate.
		self halt. ].
	^ result
]

{ #category : #'*SpyLite' }
Object >> depthIsLowerThan: aNumber [
	| semaphore process result timeOut |
	result := false.
	semaphore := Semaphore new.
	process := [ 
	[ result := self objectDepth < aNumber.
		semaphore signal.
	] on: Error
	do: [ semaphore signal ]] fork.
	timeOut := semaphore waitTimeoutMSecs: 1000.
	timeOut ifTrue: [ 
		process terminate.
		self halt. ].
	^ result
]

{ #category : #'*SpyLite' }
Object >> isASimpleObject [
	^ self depthIsLowerThan: 10
]

{ #category : #'*SpyLite' }
Object >> isSpy [

	^ false
]

{ #category : #'*SpyLite' }
Object >> isSpyMethod [

	^ false
]

{ #category : #'*SpyLite' }
Object >> isUncleanedBlock [
	^ (self isBlock and: [self isClean not]) 
]

{ #category : #'*SpyLite' }
Object >> objectDepth [ 
	|result instVarsDepth |
	result := 1.
	instVarsDepth := ( 1 to: self class instSize ) collect: [ :i | (self instVarAt: i) objectDepth ].
	instVarsDepth := instVarsDepth asOrderedCollection addAll: (( 1 to: self basicSize ) collect: [ :i | (self basicAt: i) objectDepth ]); yourself.
	instVarsDepth ifNotEmpty: [ result := result + instVarsDepth max ].
	^ result
]
