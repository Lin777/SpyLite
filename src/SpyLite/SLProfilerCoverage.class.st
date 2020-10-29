Class {
	#name : #SLProfilerCoverage,
	#superclass : #SLProfiler,
	#instVars : [
		'typeInfo'
	],
	#category : #'SpyLite-Coverage'
}

{ #category : #hooks }
SLProfilerCoverage class >> spyClassForPackage [
	^ SLPackageCoverage
]

{ #category : #hooks }
SLProfilerCoverage >> beforeProfiling [
	self allMethods select: #isNotMethodExtension thenDo: #installGhosts.
]

{ #category : #calculations }
SLProfilerCoverage >> branchCoverage1 [
	^ (self calculateExecutedBranchsByClass associations
		collect: [ :assoc | 
			| dataExecStmts |
			dataExecStmts := assoc value. "it contains: number of statements of class methods, number of executed statements"
			dataExecStmts first > 0 ifFalse: [ assoc key -> 0 ] ifTrue: [ 
			assoc key
				->
					(((100 * dataExecStmts second / dataExecStmts first)
						asFloat) round: 3) ]]) asDictionary
]

{ #category : #calculations }
SLProfilerCoverage >> branchCoverageFor: aTargetClass [
	[| executedStatements |
	executedStatements := self calculateExecutedPathsOf: aTargetClass.
	^ ((executedStatements second / executedStatements first) * 100 asFloat) round: 3]
 on: Error
do: [ ^ 0 ]
]

{ #category : #calculations }
SLProfilerCoverage >> calculateExecutedBranchsByClass [
	^ (self allClassesAsDictionary keys
		collect:
			[ :aClassName | aClassName -> (self calculateExecutedPathsOf: aClassName) ] thenSelect: [:assoc | assoc value second > 0])
		asDictionary
]

{ #category : #calculations }
SLProfilerCoverage >> calculateExecutedMethodsByClass [
	^ (self allClassesAsDictionary keys
		collect: [ :aClassName | aClassName -> (self calculateExecutedMethodsOf: aClassName) ])
		asDictionary
]

{ #category : #calculations }
SLProfilerCoverage >> calculateExecutedMethodsOf: aSymbol [
	| methods |
	methods := (self classAt: aSymbol) allMethods.
	^ Array with: methods size with: (self selectExecutedMethods: methods) size
]

{ #category : #calculations }
SLProfilerCoverage >> calculateExecutedPathsOf: aSymbol [
	| methods numStmts |
	methods := (self classAt: aSymbol) allMethods.
	numStmts := methods ifEmpty: [ 0 ] ifNotEmpty: [ (methods collect: [ :m | m cyclomaticNumber ] ) sum ].
	^ Array with: numStmts with: 
	   (methods
		inject: 0
		into: [ :sum :method | sum + method coveredPaths size ])
]

{ #category : #calculations }
SLProfilerCoverage >> calculateExecutedStatementsByClass [
	^ (self allClassesAsDictionary keys
		collect:
			[ :aClassName | aClassName -> (self calculateExecutedStatementsOf: aClassName) ] thenSelect: [:assoc | assoc value second > 0])
		asDictionary
]

{ #category : #calculations }
SLProfilerCoverage >> calculateExecutedStatementsOf: aSymbol [
	| methods numStmts |
	methods := (self classAt: aSymbol) allMethods.
	numStmts := methods ifEmpty: [ 0 ] ifNotEmpty: [ (methods collect: #numberOfAllStatements ) sum ].
	^ Array with: numStmts with: 
	   (methods
		inject: 0
		into: [ :sum :method | sum + method numberOfExecutedStatements ])
]

{ #category : #cleaning }
SLProfilerCoverage >> cleanBlocksOfMethods [
	self allMethods do: [ :aMethod | 
		aMethod "cleanBlocks"resetValues
	]
]

{ #category : #calculations }
SLProfilerCoverage >> collectExecutedMethodsByClass [
	^ self collectExecutedMethodsOfClasses: self allClassesAsDictionary keys
]

{ #category : #calculations }
SLProfilerCoverage >> collectExecutedMethodsOf: aClassName [
	| methods |
	methods := (self classAt: aClassName) allMethods.
	methods := methods select: [ :mth | mth blocks anySatisfy: #wasExecuted ].
	^ Dictionary newFrom: (methods collect: [ :m | m asString -> m blocks deepCopy ]).
	
]

{ #category : #calculations }
SLProfilerCoverage >> collectExecutedMethodsOfClasses: classes [
	| result |
	result := Dictionary new.
	(classes
		collect:
			[ :aClassName | self collectExecutedMethodsOf: aClassName ]) do: [ :d |result addAll: d ].
	^ result
	
]

{ #category : #calculations }
SLProfilerCoverage >> methodCoverage [
	| methods |
	methods := self allMethods.
	methods isEmpty
		ifTrue: [ ^ 0 ].
	^ ((100 * self numberOfExecutedMethods / methods size) asFloat) round: 3
]

{ #category : #calculations }
SLProfilerCoverage >> methodCoverage1 [
	^ (self calculateExecutedMethodsByClass associations
		collect: [ :assoc | 
			| aClassName dataExecMethods |
			aClassName := assoc key.
			dataExecMethods := assoc value.  "it contains: number of methods, number of executed methods"
			dataExecMethods first > 0 ifTrue: [ 
			aClassName
				-> (((100 * dataExecMethods second / dataExecMethods first ) asFloat) round: 3) ] ifFalse: [ aClassName -> 0 ]])
		asDictionary
]

{ #category : #accessing }
SLProfilerCoverage >> numberOfAllStatements [
	^ self allMethods
		inject: 0
		into: [ :sum :method | sum + method numberOfAllStatements ].
]

{ #category : #accessing }
SLProfilerCoverage >> numberOfExecutedMethods [
	"| methodsWithBlocks |
	methodsWithBlocks := self allMethods select: [ :aMethod | aMethod blocks isNotEmpty ].
	^ (methodsWithBlocks 
		collect: [ :aMethod | aMethod blocks first ]
		thenSelect: [ :aBlock | aBlock wasExecuted ])"
	^ (self selectExecutedMethods: self allMethods) size 
]

{ #category : #accessing }
SLProfilerCoverage >> numberOfExecutedStatements [
	^ self allMethods
		inject: 0
		into: [ :sum :method | sum + method numberOfExecutedStatements ]
]

{ #category : #filtering }
SLProfilerCoverage >> selectExecutedMethods: aList [
	^ (aList select: [ :aMethod | aMethod blocks isNotEmpty ])
		select: [ :aMethod | aMethod blocks first wasExecuted ]
]

{ #category : #calculations }
SLProfilerCoverage >> statementCoverage [
	self numberOfAllStatements == 0
		ifTrue: [ ^ 0 ].
	^ ((100 * self numberOfExecutedStatements / self numberOfAllStatements)
		asFloat) round: 3
]

{ #category : #calculations }
SLProfilerCoverage >> statementCoverage1 [
	^ (self calculateExecutedStatementsByClass associations
		collect: [ :assoc | 
			| dataExecStmts |
			dataExecStmts := assoc value. "it contains: number of statements of class methods, number of executed statements"
			dataExecStmts first > 0 ifFalse: [ assoc key -> 0 ] ifTrue: [ 
			assoc key
				->
					(((100 * dataExecStmts second / dataExecStmts first)
						asFloat) round: 3) ]]) asDictionary
]

{ #category : #calculations }
SLProfilerCoverage >> statementCoverageFor: aTargetClass [
	[| executedStatements |
	executedStatements := self calculateExecutedStatementsOf: aTargetClass.
	^ ((executedStatements second / executedStatements first) * 100 asFloat) round: 3]
 on: Error
do: [ ^ 0 ]
]

{ #category : #summaries }
SLProfilerCoverage >> summaryExecutionMethods [
	^ (self selectExecutedMethods: self allMethods) collect: [ :method | 
		SLSummaryExecutionMethod on: method ]
]

{ #category : #summaries }
SLProfilerCoverage >> summaryMethodsOf: aTargetClass [
	| aSTypeClassInfo |
	aSTypeClassInfo := (typeInfo classAt: aTargetClass).
	^ (self classAt: aTargetClass) allMethods collect: [ :method | | summary methodTypeInfo |
		summary := SLSummaryExecutionMethod on: method.
		methodTypeInfo := (method isClassSide ifTrue: [ aSTypeClassInfo classMethodTypes ]
		ifFalse: [ aSTypeClassInfo methodTypes ]) at: method selector ifAbsent: [nil].
		methodTypeInfo ifNotNil: [ summary updateTypeInfoWith: methodTypeInfo ] ]
]

{ #category : #accessing }
SLProfilerCoverage >> typeInfo [
	^ typeInfo
]

{ #category : #accessing }
SLProfilerCoverage >> typeInfo: anObject [
	typeInfo := anObject
]

{ #category : #updating }
SLProfilerCoverage >> updateClass: aClassCoverage [
	self packages do: [ :pack | 
		pack classes 
			at: aClassCoverage className
			ifPresent: [ :val | aClassCoverage localMethods do: [ :meth | meth classSpy: val ] .
				aClassCoverage metaclassSpy localMethods do: [ :meth | meth classSpy: val metaclassSpy ] .
				val methods: aClassCoverage localMethods.
				val metaclassSpy methods: aClassCoverage metaclassSpy localMethods.
				pack classes at: aClassCoverage className put: val ] ]
]
