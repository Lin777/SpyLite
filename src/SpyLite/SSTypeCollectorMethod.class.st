"
SSTypeCollectorMethod is a subclass of profiler method that collects method types.

Instance Variables
	argTypes:			<Collection>
	executed:			<False>
	receiverType:	<SMultiTypeInfo>
	returnType:		<SMultiTypeInfo>
"
Class {
	#name : #SSTypeCollectorMethod,
	#superclass : #SLMethod,
	#instVars : [
		'returnType',
		'argTypes',
		'receiverType',
		'executed',
		'literals',
		'numberOfExecutions'
	],
	#category : #'SpyLite-TypeCollector'
}

{ #category : #accessing }
SSTypeCollectorMethod >> argTypes [
	^ argTypes
]

{ #category : #hooks }
SSTypeCollectorMethod >> beforeRun: methodName with: listOfArguments in: aReceiver [
	self saveArguments: listOfArguments.
	self saveReceiver: aReceiver.
	self selectLiteralsOf: self originalMethod sourceCode.
	listOfArguments do: [ :arg | self checkIfArgIsScalar: arg ].
	executed := true.
	numberOfExecutions := numberOfExecutions + 1
]

{ #category : #hooks }
SSTypeCollectorMethod >> checkIfArgIsScalar: arg [
	| argType scalarShouldBeAdded |
	argType := arg class name.
	scalarShouldBeAdded := self profiler scalars at: argType ifPresent: [true] ifAbsent: [ nil ].
	scalarShouldBeAdded 
		ifNil: [ scalarShouldBeAdded := self profiler nonScalars like: argType.
			scalarShouldBeAdded ifNotNil: [ scalarShouldBeAdded := false ] ].
	scalarShouldBeAdded
		ifNil: [ scalarShouldBeAdded := 
			(self profiler isScalar: arg) and: [ arg isASimpleObject ] ].
	(scalarShouldBeAdded and: [ arg containUncleanedBlocks ])
		ifTrue: [ self profiler addScalar: arg ]
		ifFalse: [ self profiler addNonScalar: argType ]
]

{ #category : #accessing }
SSTypeCollectorMethod >> dictLiterals [
	^ literals

	
]

{ #category : #hooks }
SSTypeCollectorMethod >> initialize [
	super initialize.
	returnType := Set new.
	receiverType := Set new.
	argTypes := OrderedCollection new.
	executed := false.
	numberOfExecutions := 0.
	literals := Dictionary new
]

{ #category : #testing }
SSTypeCollectorMethod >> isDeprecated [ 
	^ originalMethod isDeprecated 
]

{ #category : #testing }
SSTypeCollectorMethod >> isValidReturnTypeWithReceiver [
	^ self receiverType = self returnType
]

{ #category : #hooks }
SSTypeCollectorMethod >> numberOfExecutions [
	^ numberOfExecutions
]

{ #category : #hooks }
SSTypeCollectorMethod >> numberOfExecutions: aNumber [
	numberOfExecutions := aNumber 
]

{ #category : #accessing }
SSTypeCollectorMethod >> receiverType [
	
	^ receiverType
]

{ #category : #accessing }
SSTypeCollectorMethod >> returnType [
	^ returnType
]

{ #category : #hooks }
SSTypeCollectorMethod >> returnValue: value [
	returnType add: (self nameOf: value class).
	self checkIfArgIsScalar: value
]

{ #category : #hooks }
SSTypeCollectorMethod >> saveArguments: args [
	args
		doWithIndex: [ :anObject :index | 
			[ argTypes at: index ]
				on: SubscriptOutOfBounds
				do: [ argTypes add: Set new ].
			(argTypes at: index) add: (self nameOf: anObject class) ]
]

{ #category : #hooks }
SSTypeCollectorMethod >> saveReceiver: anObject [
	receiverType
		add:
			(self nameOf: anObject )
]

{ #category : #hooks }
SSTypeCollectorMethod >> selectLiteralsOf: string [
	| node visitor |
	node := RBParser parseMethod: string.
	visitor := SLCollectorLiteral new.
	node acceptVisitor: visitor.
	literals := visitor literals
]

{ #category : #hooks }
SSTypeCollectorMethod >> wasExecuted [
	^ executed.
]
