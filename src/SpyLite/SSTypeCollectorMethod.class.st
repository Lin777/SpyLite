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
		'literals'
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
	executed := true
]

{ #category : #hooks }
SSTypeCollectorMethod >> checkIfArgIsScalar: arg [
	(self profiler isScalar: arg)
		ifTrue: [ self profiler addScalar: arg ]
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
SSTypeCollectorMethod >> nameOf: anObject [
	^ (anObject isClass
				ifTrue: [ anObject name ]
				ifFalse: [ anObject class name ])
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
	returnType add: value class name.
	self checkIfArgIsScalar: value
]

{ #category : #hooks }
SSTypeCollectorMethod >> saveArguments: args [
	args
		doWithIndex: [ :anObject :index | 
			[ argTypes at: index ]
				on: SubscriptOutOfBounds
				do: [ argTypes add: Set new ].
			(argTypes at: index) add: anObject class name ]
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
	visitor := SVisitorNode new.
	node acceptVisitor: visitor.
	literals := visitor literals
]

{ #category : #hooks }
SSTypeCollectorMethod >> wasExecuted [
	^ executed.
]
