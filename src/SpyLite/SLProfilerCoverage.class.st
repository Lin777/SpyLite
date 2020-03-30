Class {
	#name : #SLProfilerCoverage,
	#superclass : #SLProfiler,
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

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> calculateExecutedMethodsByClass [
	^ (self allClassesAsDictionary keys
		collect: [ :aClassName | aClassName -> (self calculateExecutedMethodsOf: aClassName) ])
		asDictionary
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> calculateExecutedMethodsOf: aSymbol [
	| methods |
	methods := (self classAt: aSymbol) allMethods.
	^ Array with: methods size with: (self selectExecutedMethods: methods) size
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> calculateExecutedStatementsByClass [
	^ (self allClassesAsDictionary keys
		collect:
			[ :aClassName | aClassName -> (self calculateExecutedStatementsOf: aClassName) ] thenSelect: [:assoc | assoc value second > 0])
		asDictionary
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> calculateExecutedStatementsOf: aSymbol [
	| methods numStmts |
	methods := (self classAt: aSymbol) allMethods.
	numStmts := methods ifEmpty: [ 0 ] ifNotEmpty: [ (methods collect: #numberOfAllStatements ) sum ].
	^ Array with: numStmts with: 
	   (methods
		inject: 0
		into: [ :sum :method | sum + method numberOfExecutedStatements ])
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> cleanBlocksOfMethods [
	self allMethods do: [ :aMethod | 
		aMethod blocks do: [ :aBlock | aBlock noExecuted ]	
	]
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> methodCoverage [
	| methods |
	methods := self allMethods.
	methods isEmpty
		ifTrue: [ ^ 0 ].
	^ ((100 * self numberOfExecutedMethods / methods size) asFloat) round: 3
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> numberOfAllStatements [
	^ self allMethods
		inject: 0
		into: [ :sum :method | sum + method numberOfAllStatements ].
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> numberOfExecutedMethods [
	"| methodsWithBlocks |
	methodsWithBlocks := self allMethods select: [ :aMethod | aMethod blocks isNotEmpty ].
	^ (methodsWithBlocks 
		collect: [ :aMethod | aMethod blocks first ]
		thenSelect: [ :aBlock | aBlock wasExecuted ])"
	^ (self selectExecutedMethods: self allMethods) size 
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> numberOfExecutedStatements [
	^ self allMethods
		inject: 0
		into: [ :sum :method | sum + method numberOfExecutedStatements ]
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> selectExecutedMethods: aList [
	^ (aList select: [ :aMethod | aMethod blocks isNotEmpty ])
		select: [ :aMethod | aMethod blocks first wasExecuted ]
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> statementCoverage [
	self numberOfAllStatements == 0
		ifTrue: [ ^ 0 ].
	^ ((100 * self numberOfExecutedStatements / self numberOfAllStatements)
		asFloat) round: 3
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> statementCoverageFor: aTargetClass [
	| executedStatements |
	executedStatements := self calculateExecutedStatementsOf: aTargetClass.
	^ ((executedStatements second / executedStatements first) * 100 asFloat) round: 3
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> summaryExecutedCode [
	^ ((self selectExecutedMethods: self allMethods) collect: [ :method | 
		(method classSpy className -> method selector) -> (method blocks collect: [:block | 
			Array with: block wasExecuted with: block code])
	]) asDictionary
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> updateClass: aClassCoverage [
	self packages do: [ :pack | 
		pack classes 
			at: aClassCoverage className
			ifPresent: [ :val | aClassCoverage localMethods do: [ :meth | meth classSpy: val ] .
				aClassCoverage metaclassSpy localMethods do: [ :meth | meth classSpy: val metaclassSpy ] .
				val methods: aClassCoverage localMethods.
				val metaclassSpy methods: aClassCoverage metaclassSpy localMethods.
				pack classes at: aClassCoverage className put: val ]
		]
]
