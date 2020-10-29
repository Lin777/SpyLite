Class {
	#name : #SLMethodCoverage,
	#superclass : #SLMethod,
	#instVars : [
		'blocks',
		'probedMethod',
		'cyclomaticNumber',
		'coveredPaths'
	],
	#category : #'SpyLite-Coverage'
}

{ #category : #'initialize-release' }
SLMethodCoverage >> addPath: aPath [
	coveredPaths add: aPath
]

{ #category : #accessing }
SLMethodCoverage >> blocks [
	^ blocks
]

{ #category : #reseting }
SLMethodCoverage >> cleanBlocks [ 
	self blocks do: [ :aBlock | aBlock noExecuted ]	
]

{ #category : #reseting }
SLMethodCoverage >> cleanPaths [
	coveredPaths := Set new.
]

{ #category : #enumerating }
SLMethodCoverage >> count: aNumber [
	blocks detect:[:block| block id = aNumber] ifFound:[ :block | 
		self updateStateFirstBlock.
		block executed]
]

{ #category : #accessing }
SLMethodCoverage >> coveredPaths [
	^ coveredPaths
]

{ #category : #accessing }
SLMethodCoverage >> cyclomaticNumber [
	^ cyclomaticNumber
]

{ #category : #accessing }
SLMethodCoverage >> executedBlocks [
	^ coveredPaths flattened asSet
]

{ #category : #'initialize-release' }
SLMethodCoverage >> executedPath [
	^ (self blocks select: [ :e | e wasExecuted ] thenCollect: [ :e | e id ]) asArray
]

{ #category : #'initialize-release' }
SLMethodCoverage >> initialize [ 	
	super initialize.
	cyclomaticNumber := 1.
	blocks := OrderedCollection new.
	coveredPaths := Set new.
]

{ #category : #installing }
SLMethodCoverage >> installGhosts [
	| rbMethodNode newMethod aClass |
	"self selector = #pic ifTrue: [ self halt ]."
	self originalMethod sourceCode size > 20000 
	ifTrue: [ self uninstall ]
	ifFalse: [ [ rbMethodNode := RBParser
		parseMethod: self originalMethod sourceCode.
	cyclomaticNumber := (SLVisitorForCyclomaticMetric for: rbMethodNode) cyclomaticNumber.
	blocks := SLInstrumentor new
		visitNode: rbMethodNode;
		blocks.
	aClass := self originalMethod methodClass.
	newMethod := aClass compile: rbMethodNode printString notifying: nil.
	aClass >> newMethod replaceLiterals: (Array with: (#metaObject -> self)) ]
		on: Error
		do: [ :e | self uninstall ] ]
]

{ #category : #'public - metrics' }
SLMethodCoverage >> numberOfAllStatements [
	^ self blocks inject: 0 into:[:sum :block| sum + block numberOfStatements]
]

{ #category : #'public - metrics' }
SLMethodCoverage >> numberOfExecutedStatements [
	^ ("self blocks select: #wasExecuted"
	self executedBlocks collect: [ :index | self blocks at: index ])
		inject: 0
		into: [ :sum :block | sum + block numberOfStatements ]
]

{ #category : #reseting }
SLMethodCoverage >> resetValues [
	self cleanBlocks.
	self cleanPaths.
]

{ #category : #updating }
SLMethodCoverage >> updateStateFirstBlock [
	blocks ifNotEmpty: [ blocks first executed ]
]
