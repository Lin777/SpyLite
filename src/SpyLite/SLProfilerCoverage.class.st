Class {
	#name : #SLProfilerCoverage,
	#superclass : #SLProfiler,
	#category : #'SpyLite-MetaModel'
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
	^ ((methods
		select: [ :aMethod | aMethod blocks isNotEmpty ]
		thenCollect: [ :aMethod | aMethod blocks first ])
		select: [ :aBlock | aBlock wasExecuted ]) size
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> calculateExecutedStatementsByClass [
	^ (self allClassesAsDictionary keys
		collect:
			[ :aClassName | aClassName -> (self calculateExecutedStatementsOf: aClassName) ] thenSelect: [:assoc | assoc value > 0])
		asDictionary
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> calculateExecutedStatementsOf: aSymbol [
	| methods |
	methods := (self classAt: aSymbol) allMethods.
	^ (methods
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
	| numberMethods |
	numberMethods := self allMethods size.
	^ (self calculateExecutedMethodsByClass associations
		collect: [ :assoc | 
			| aClassName |
			aClassName := assoc key.
			numberMethods > 0 ifTrue: [ 
			aClassName
				-> (((100 * assoc value / numberMethods ) asFloat) round: 3)	"(self classAt: aClassName)" ] ifFalse: [ aClassName -> 0 ]])
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
	| methodsWithBlocks |
	methodsWithBlocks := self allMethods select: [ :aMethod | aMethod blocks isNotEmpty ].
	^ (methodsWithBlocks 
		collect: [ :aMethod | aMethod blocks first ]
		thenSelect: [ :aBlock | aBlock wasExecuted ]) size 
]

{ #category : #'as yet unclassified' }
SLProfilerCoverage >> numberOfExecutedStatements [
	^ self allMethods
		inject: 0
		into: [ :sum :method | sum + method numberOfExecutedStatements ]
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
	| numb|
	numb := self numberOfAllStatements.
	^ (self calculateExecutedStatementsByClass associations
		collect: [ :assoc | 
			numb > 0 ifFalse: [ assoc key -> 0 ] ifTrue: [ 
			assoc key
				->
					(((100 * assoc value / "(self classAt: assoc key)"self numberOfAllStatements)
						asFloat) round: 3) ]]) asDictionary
]
