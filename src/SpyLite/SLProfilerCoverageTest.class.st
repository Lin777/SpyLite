Class {
	#name : #SLProfilerCoverageTest,
	#superclass : #TestCase,
	#category : #'SpyLite-Tests'
}

{ #category : #'as yet unclassified' }
SLProfilerCoverageTest >> asserMethodCoverage: profiler toNoExecutedMethods: aNumber [
	self assert: profiler methodCoverage closeTo: ((100 * aNumber / profiler allMethods size) asFloat round: 2)
]

{ #category : #asserting }
SLProfilerCoverageTest >> assert: aObject class: aClass [
	self assert: aObject className equals: aClass name asString
]

{ #category : #'as yet unclassified' }
SLProfilerCoverageTest >> assertMethodCoverageOf: profiler on: symbol equals: number [
	| dictMethodCoverage |
	dictMethodCoverage := profiler methodCoverage1.
	self
		assert: (dictMethodCoverage at: symbol)
		closeTo: number
]

{ #category : #asserting }
SLProfilerCoverageTest >> assertNoExecutedMethods: profiler equals: aNumber [
	self assert: profiler numberOfExecutedMethods equals: aNumber
]

{ #category : #asserting }
SLProfilerCoverageTest >> assertNumExecutedMethodsOf: profiler on: symbol equals: number [
	| dict |
	dict := profiler calculateExecutedMethodsByClass.
	self assert: (dict at: symbol) equals: number
]

{ #category : #asserting }
SLProfilerCoverageTest >> assertNumExecutedStatementsOf: profiler on: symbol equals: number [
	| dict |
	dict := profiler calculateExecutedStatementsByClass.
	self assert: (dict at: symbol) equals: number
]

{ #category : #'as yet unclassified' }
SLProfilerCoverageTest >> assertStatementCoverageOf: profiler on: symbol equals: number [
	| dictMethodCoverage |
	dictMethodCoverage := profiler statementCoverage1.
	self
		assert: (dictMethodCoverage at: symbol)
		equals: number
]

{ #category : #api }
SLProfilerCoverageTest >> clean: aProfiler [
	aProfiler cleanInstrumentation.
	"SLProfilerCoverage resetInstance."
]

{ #category : #running }
SLProfilerCoverageTest >> tearDown [
"	S2Lock value: false.
	S2Context value: nil.
	S2Profiler remove."
	super tearDown
]

{ #category : #tests }
SLProfilerCoverageTest >> testMethodCoverage [
	| profiler |
	profiler := SLProfilerCoverage
		profile: [ SBCounting new ]
		inPackagesMatching: 'SBTCEx*'.
	self assertNumExecutedMethodsOf: profiler on: #SBCounting equals: 0.
	self assertMethodCoverageOf: profiler on: #SBCounting equals: 0.
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new one ]
		inPackagesMatching: 'SBTCEx*'.
	self assertNumExecutedMethodsOf: profiler on: #SBCounting equals: 1.
	self assertMethodCoverageOf: profiler on: #SBCounting equals: ((1/7) asFloat  * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new anAssignment ]
		inPackagesMatching: 'SBTCEx*'.
	self assertNumExecutedMethodsOf: profiler on: #SBCounting equals: 1.
	self assertMethodCoverageOf: profiler on: #SBCounting equals: ((1/7) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new main ]
		inPackagesMatching: 'SBTCEx*'.
	self assertNumExecutedMethodsOf: profiler on: #SBCounting equals: 2.
	self assertMethodCoverageOf: profiler on: #SBCounting equals: ((2/7) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new methWithCondition ]
		inPackagesMatching: 'SBTCEx*'.
	self assertNumExecutedMethodsOf: profiler on: #SBCounting equals: 1.
	self assertMethodCoverageOf: profiler on: #SBCounting equals: ((1/7) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new methMix ]
		inPackagesMatching: 'SBTCEx*'.
	self assertNumExecutedMethodsOf: profiler on: #SBCounting equals: 1.
	self assertMethodCoverageOf: profiler on: #SBCounting equals: ((1/7) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new methWithComposeBlocks ]
		inPackagesMatching: 'SBTCEx*'.
	self assertNumExecutedMethodsOf: profiler on: #SBCounting equals: 1.
	self assertMethodCoverageOf: profiler on: #SBCounting equals: ((1/7) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new methWithArguments: #(2 6 8 13 5 9 11 13) ]
		inPackagesMatching: 'SBTCEx*'.
	self assertNumExecutedMethodsOf: profiler on: #SBCounting equals: 1.
	self assertMethodCoverageOf: profiler on: #SBCounting equals: ((1/7) asFloat * 100 round: 3).
	self clean: profiler
]

{ #category : #tests }
SLProfilerCoverageTest >> testProfileOnPackagesMatching [
	| profiler |
	profiler := SLProfilerCoverage
		profile: [ SBCounting new ]
		inPackagesMatching: 'SBTCEx*'.
	self assert: profiler class: SLProfilerCoverage.
	self assertMethodCoverageOf: profiler on: #SBCounting equals: 0.
	self assert: profiler statementCoverage1 isEmpty.
	self clean: profiler
]

{ #category : #tests }
SLProfilerCoverageTest >> testStatementCoverage [
	| profiler |
	profiler := SLProfilerCoverage
		profile: [ SBCounting new ]
		inPackagesMatching: 'SBTCEx*'.
	self assert: profiler numberOfAllStatements equals: 27.
	self assert: profiler statementCoverage1 isEmpty.
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new one ]
		inPackagesMatching: 'SBTCEx*'.
	self
		assertNumExecutedStatementsOf: profiler
		on: #SBCounting
		equals: 1.
	self assertStatementCoverageOf: profiler on: #SBCounting equals: ((1 / 27) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new anAssignment ]
		inPackagesMatching: 'SBTCEx*'.
	self
		assertNumExecutedStatementsOf: profiler
		on: #SBCounting
		equals: 2.
	self assertStatementCoverageOf: profiler on: #SBCounting equals: ((2 / 27) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new main ]
		inPackagesMatching: 'SBTCEx*'.
	self
		assertNumExecutedStatementsOf: profiler
		on: #SBCounting
		equals: 2.
	self assertStatementCoverageOf: profiler on: #SBCounting equals: ((2 / 27) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new methWithCondition ]
		inPackagesMatching: 'SBTCEx*'.
	self
		assertNumExecutedStatementsOf: profiler
		on: #SBCounting
		equals: 2.
	self assertStatementCoverageOf: profiler on: #SBCounting equals: ((2 / 27) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new methMix ]
		inPackagesMatching: 'SBTCEx*'.
	self
		assertNumExecutedStatementsOf: profiler
		on: #SBCounting
		equals: 5.
	self assertStatementCoverageOf: profiler on: #SBCounting equals: ((5 / 27) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new methWithComposeBlocks ]
		inPackagesMatching: 'SBTCEx*'.
	self assert: profiler numberOfExecutedStatements equals: 7.
	self assertStatementCoverageOf: profiler on: #SBCounting equals: ((7 / 27) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new methWithArguments: #(2 6 8 13 5 9 11 13) ]
		inPackagesMatching: 'SBTCEx*'.
	self
		assertNumExecutedStatementsOf: profiler
		on: #SBCounting
		equals: 6.
	self assertStatementCoverageOf: profiler on: #SBCounting equals: ((6 / 27) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new methWithArguments: #(1 4 6 7) ]
		inPackagesMatching: 'SBTCEx*'.
	self
		assertNumExecutedStatementsOf: profiler
		on: #SBCounting
		equals: 6.
	self assertStatementCoverageOf: profiler on: #SBCounting equals: ((6 / 27) asFloat * 100 round: 3).
	self clean: profiler.
	profiler := SLProfilerCoverage
		profile: [ SBCounting new methWithArguments: #(4 6 12) ]
		inPackagesMatching: 'SBTCEx*'.
	self
		assertNumExecutedStatementsOf: profiler
		on: #SBCounting
		equals: 4.
	self assertStatementCoverageOf: profiler on: #SBCounting equals: ((4 / 27) asFloat * 100 round: 3).
	self clean: profiler
]
