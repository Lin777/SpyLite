Class {
	#name : #SLSummaryExecutionMethod,
	#superclass : #Object,
	#instVars : [
		'executorClass',
		'selector',
		'executed',
		'code',
		'summaryStatements',
		'isClassSide',
		'hasProfiler',
		'returnType',
		'argsTypes'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #'instance creation' }
SLSummaryExecutionMethod class >> on: slMethod [
	^ self new 
		executorClass: slMethod classSpy className;
		selector: slMethod selector;
		code: ([slMethod blocks first code] on: SubscriptOutOfBounds do: ['']);
		executed: ([slMethod blocks first wasExecuted] on: SubscriptOutOfBounds do: [ false ]);
		isClassSide: slMethod isClassSide;
		summaryStatements: (slMethod blocks allButFirst collect: [:block | 
			SLSummaryStatement with: block code and: block wasExecuted 	
		])
]

{ #category : #comparing }
SLSummaryExecutionMethod >> = another [ 
	^ (self class = another class) 
		and: [ (selector = another selector) 
			and: [ (executed = another executed ) 
				and: [ (executorClass = another executorClass ) 
					and: [ (summaryStatements = another summaryStatements) ] ] ] ]
]

{ #category : #'testing kind' }
SLSummaryExecutionMethod >> allBlocksExecuted [
	^ executed and: [ summaryStatements allSatisfy: #executed ]
]

{ #category : #accessing }
SLSummaryExecutionMethod >> argsTypes [
	^ argsTypes
]

{ #category : #accessing }
SLSummaryExecutionMethod >> argsTypes: anObject [
	argsTypes := anObject
]

{ #category : #accessing }
SLSummaryExecutionMethod >> code [
	^ code
]

{ #category : #accessing }
SLSummaryExecutionMethod >> code: anObject [
	code := anObject
]

{ #category : #accessing }
SLSummaryExecutionMethod >> executed [
	^ executed
]

{ #category : #accessing }
SLSummaryExecutionMethod >> executed: anObject [
	executed := anObject
]

{ #category : #'testing kind' }
SLSummaryExecutionMethod >> executedBlocks [
	^ summaryStatements select: #executed
]

{ #category : #accessing }
SLSummaryExecutionMethod >> executorClass [
	^ executorClass
]

{ #category : #accessing }
SLSummaryExecutionMethod >> executorClass: anObject [
	executorClass := anObject
]

{ #category : #accessing }
SLSummaryExecutionMethod >> hasProfiler [
	^ hasProfiler
]

{ #category : #accessing }
SLSummaryExecutionMethod >> hasProfiler: anObject [
	hasProfiler := anObject
]

{ #category : #comparing }
SLSummaryExecutionMethod >> hash [
	^ summaryStatements hash
]

{ #category : #initialization }
SLSummaryExecutionMethod >> initialize [ 	
	code := ''.
	executed := false.
	summaryStatements := OrderedCollection new
]

{ #category : #accessing }
SLSummaryExecutionMethod >> isClassSide [
	^ isClassSide
]

{ #category : #accessing }
SLSummaryExecutionMethod >> isClassSide: anObject [
	isClassSide := anObject
]

{ #category : #'testing kind' }
SLSummaryExecutionMethod >> notAllBlocksExecuted [
	^ self allBlocksExecuted not
]

{ #category : #accessing }
SLSummaryExecutionMethod >> returnType [
	^ returnType
]

{ #category : #accessing }
SLSummaryExecutionMethod >> returnType: anObject [
	returnType := anObject
]

{ #category : #accessing }
SLSummaryExecutionMethod >> selector [
	^ selector
]

{ #category : #accessing }
SLSummaryExecutionMethod >> selector: anObject [
	selector := anObject
]

{ #category : #export }
SLSummaryExecutionMethod >> summaryAsColl [
	^ OrderedCollection new 
			add: executorClass;
			add: selector;
			add: isClassSide;
			add: executed;
			add: hasProfiler;
			add: code;
			add:
			(argsTypes
				ifNil: [ #() ]
				ifNotNil: [ (argsTypes collect: [ :argType | argType types asArray ]) asArray ]);
			add: returnType types asArray;
			add: (self executedBlocks collect: #code) asArray;
			add: (self unexecutedBlocks collect: #code) asArray;
			yourself 
]

{ #category : #accessing }
SLSummaryExecutionMethod >> summaryStatements [
	^ summaryStatements
]

{ #category : #accessing }
SLSummaryExecutionMethod >> summaryStatements: anObject [
	summaryStatements := anObject
]

{ #category : #accessing }
SLSummaryExecutionMethod >> unexecuted [
	^ self executed not
]

{ #category : #'testing kind' }
SLSummaryExecutionMethod >> unexecutedBlocks [
	^ summaryStatements select: [ :slBlock | slBlock executed not ]
]

{ #category : #updating }
SLSummaryExecutionMethod >> updateTypeInfoWith: aMethodTypeInfo [
	hasProfiler := aMethodTypeInfo hasProfiler.
	returnType := aMethodTypeInfo returnType.
	argsTypes := aMethodTypeInfo argTypes
]

{ #category : #export }
SLSummaryExecutionMethod >> writeDataCSV: neoCSVWriter withIndex: anInteger [
	neoCSVWriter nextPut: (Array with: anInteger 
		withAll: ( self summaryAsColl ))
]
