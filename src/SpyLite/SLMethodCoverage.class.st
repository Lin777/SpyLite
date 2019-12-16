Class {
	#name : #SLMethodCoverage,
	#superclass : #SLMethod,
	#instVars : [
		'blocks'
	],
	#category : #'SpyLite-MetaModel'
}

{ #category : #accessing }
SLMethodCoverage >> blocks [
	^ blocks
]

{ #category : #enumerating }
SLMethodCoverage >> count: aNumber [
	blocks detect:[:block| block id = aNumber] ifFound:[ :block | 
		self updateStateFirstBlock.
		block executed]
]

{ #category : #'initialize-release' }
SLMethodCoverage >> initialize [ 	
	super initialize.
	blocks := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
SLMethodCoverage >> installGhosts [
	| rbMethodNode newMethod aClass |
	"self selector = #pic ifTrue: [ self halt ]."
	self originalMethod sourceCode size > 20000 
	ifTrue: [ self uninstall ]
	ifFalse: [[ 
	rbMethodNode := RBParser
		parseMethod: self originalMethod sourceCode.
	blocks := SBInstrumentor new
		visitNode: rbMethodNode;
		blocks.
	aClass := self originalMethod methodClass.
	newMethod := aClass compile: rbMethodNode printString notifying: nil.
	aClass >> newMethod replaceLiterals: (Array with: (#metaObject -> self)) ]
		on: Error
		do: [ :e | self uninstall ]]
]

{ #category : #'public - metrics' }
SLMethodCoverage >> numberOfAllStatements [
	^ self blocks inject: 0 into:[:sum :block| sum + block numberOfStatements]
]

{ #category : #'public - metrics' }
SLMethodCoverage >> numberOfExecutedStatements [
	^ (self blocks select: #wasExecuted)
		inject: 0
		into: [ :sum :block | sum + block numberOfStatements ]
]

{ #category : #'as yet unclassified' }
SLMethodCoverage >> updateStateFirstBlock [
	blocks ifNotEmpty: [ blocks first executed ]
]
