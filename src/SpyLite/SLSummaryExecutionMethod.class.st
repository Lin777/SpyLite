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
		'argsTypes',
		'summaryAllBlocks',
		'summaryBranches',
		'summaryBlocks'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #'instance creation' }
SLSummaryExecutionMethod class >> on: slMethod [
	^ self new 
		executorClass: slMethod classSpy className;
		selector: slMethod selector;
		code: ([slMethod blocks first code] on: SubscriptOutOfBounds do: ['']);
		executed: ([slMethod coveredPaths isNotEmpty ] on: SubscriptOutOfBounds do: [ false ]);
		isClassSide: slMethod isClassSide;
		summaryStatements: (slMethod blocks allButFirst collect: [:block | 
			SLSummaryStatement on: block wasExecuted: (slMethod executedBlocks includes: block id) 	
		]);
	summaryBlocks: slMethod executedBlocks;
	summaryAllBlocks: ( Dictionary newFromKeys: (slMethod blocks collect: #id) 
		andValues: (slMethod blocks collect: #numberOfStatements) );
		summaryBranches: slMethod coveredPaths
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

{ #category : #counting }
SLSummaryExecutionMethod >> countBranchesOf: anArray [
	^ anArray size
]

{ #category : #counting }
SLSummaryExecutionMethod >> countStatementsOf: anArray [
	| statements |
	statements := anArray asArray collect: [ :e | summaryAllBlocks at: e ifAbsent: [ 0 ] ].
	^ statements ifEmpty: [ 0 ] ifNotEmpty: [ statements sum ]
]

{ #category : #diff }
SLSummaryExecutionMethod >> difference: slSummary on: aSymbol [
	| intersection news nocov myCovered otherCovered |
	myCovered := (self perform: aSymbol).
	otherCovered := (slSummary perform: aSymbol).
	intersection := myCovered intersection: otherCovered.
	news := otherCovered copyWithoutAll: intersection.
	nocov := myCovered copyWithoutAll: intersection.

	^ Array with: news with: nocov
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
	summaryStatements := OrderedCollection new.
	summaryBranches := OrderedCollection new.
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

{ #category : #accessing }
SLSummaryExecutionMethod >> summaryAllBlocks [
	^ summaryAllBlocks
]

{ #category : #accessing }
SLSummaryExecutionMethod >> summaryAllBlocks: anObject [
	summaryAllBlocks := anObject
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
SLSummaryExecutionMethod >> summaryBlocks [
	^ summaryBlocks
]

{ #category : #accessing }
SLSummaryExecutionMethod >> summaryBlocks: anObject [
	summaryBlocks := anObject
]

{ #category : #accessing }
SLSummaryExecutionMethod >> summaryBranches [
	^ summaryBranches
]

{ #category : #accessing }
SLSummaryExecutionMethod >> summaryBranches: anObject [
	summaryBranches := anObject
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
