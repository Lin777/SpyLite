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
		'numberOfExecutions',
		'orderedLiterals',
		'orderedArgTypes',
		'orderedReturnType',
		'orderedReceiverType'
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
	orderedReturnType := OrderedCollection new.
	receiverType := Set new.
	orderedReceiverType := OrderedCollection new.
	argTypes := OrderedCollection new.
	orderedArgTypes := OrderedCollection new.
	executed := false.
	numberOfExecutions := 0.
	literals := OrderedDictionary new.
	orderedLiterals := OrderedDictionary new
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
SSTypeCollectorMethod >> orderedArgTypes [
	^ orderedArgTypes 
]

{ #category : #accessing }
SSTypeCollectorMethod >> orderedLiterals [
	^ orderedLiterals
]

{ #category : #accessing }
SSTypeCollectorMethod >> orderedReceiverType [
	^ orderedReceiverType
]

{ #category : #accessing }
SSTypeCollectorMethod >> orderedReturnType [
	^ orderedReturnType 
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
	| nameOfClass |
	nameOfClass := self nameOf: value class.
	(returnType includes: nameOfClass) ifFalse: [ orderedReturnType add: nameOfClass ].
	returnType add: nameOfClass.
	self checkIfArgIsScalar: value
]

{ #category : #hooks }
SSTypeCollectorMethod >> saveArguments: args [
	args
		doWithIndex: [ :anObject :index | | nameOfClass set coll |
			nameOfClass := self nameOf: anObject class.
			[ argTypes at: index ]
				on: SubscriptOutOfBounds
				do: [ argTypes add: Set new.
					orderedArgTypes add: OrderedCollection new ].
			set := argTypes at: index.
			coll := orderedArgTypes at: index.
			(set includes: nameOfClass) 
				ifFalse: [ coll add: nameOfClass  ].
			set add: nameOfClass ]
]

{ #category : #hooks }
SSTypeCollectorMethod >> saveReceiver: anObject [
	| nameOfClass |
	nameOfClass := self nameOf: anObject.
	(receiverType includes: nameOfClass) ifFalse: [ orderedReceiverType add: nameOfClass ].
	receiverType add: nameOfClass
]

{ #category : #hooks }
SSTypeCollectorMethod >> selectLiteralsOf: string [
	| node visitor |
	node := RBParser parseMethod: string.
	visitor := SLCollectorLiteral new.
	node acceptVisitor: visitor.
	literals := visitor orderedLiterals
]

{ #category : #hooks }
SSTypeCollectorMethod >> wasExecuted [
	^ executed.
]
