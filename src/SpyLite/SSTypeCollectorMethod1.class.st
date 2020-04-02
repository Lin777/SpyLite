Class {
	#name : #SSTypeCollectorMethod1,
	#superclass : #SSTypeCollectorMethod,
	#category : #'SpyLite-TypeCollector'
}

{ #category : #hooks }
SSTypeCollectorMethod1 >> beforeRun: methodName with: listOfArguments in: aReceiver [
	self saveReceiver: aReceiver.
	self selectLiteralsOf: self originalMethod sourceCode.
	listOfArguments do: [ :arg | self checkIfArgIsScalar: arg ].
	executed := true.
	numberOfExecutions := numberOfExecutions + 1
]

{ #category : #hooks }
SSTypeCollectorMethod1 >> initialize [
	super initialize.
	returnType := OrderedCollection new.
]

{ #category : #hooks }
SSTypeCollectorMethod1 >> run: methodName with: listOfArguments in: receiver [
	| v copyArgs |
	
	copyArgs := listOfArguments copy.
	self beforeRun: methodName with: listOfArguments in: receiver.
	self classSpy ifNotNil: [
		classSpy beforeEachExecution: methodName On: receiver with: listOfArguments ].
	
	v := originalMethod valueWithReceiver: receiver arguments: listOfArguments.
	self afterRun: methodName with: listOfArguments in: receiver.

	self classSpy ifNotNil: [ 
		classSpy afterEachExecution: methodName On: receiver with: listOfArguments ].
	copyArgs ifNil: [ self returnValue: v ]
	ifNotNil: [self saveArgs: copyArgs withReturn: v].

	^ v
]

{ #category : #hooks }
SSTypeCollectorMethod1 >> saveArgs: args withReturn: anObject [
	| argsClasses returnClasses |
	argsClasses := args collect: [:e | (self nameOf: e class)].
	returnClasses := self nameOf: anObject class.
	argTypes doWithIndex: [ :each :i |
		((each = argsClasses) and: [ (returnType at: i) = returnClasses ]) 
			ifTrue: [ ^ self ] ].
	self returnValue: anObject.
	argTypes add: argsClasses.
	
]
