Class {
	#name : #SLVisitorForCyclomaticMetric,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'cyclomaticNumber',
		'methodNode'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #'instance creation' }
SLVisitorForCyclomaticMetric class >> for: aMethod [
	^ self new
		processMethod: aMethod;
		yourself
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> computeCyclomaticNumber: sel [
	"The following equations defined McCabe Cyclomatic Complexity:

	     1.The number of regions in a flow graph. 
     		2.V(G) = E - N + 2, where E are the edges and N are the nodes. 
     		3.V(G) = P + 1, where P are the predicate nodes. 

	The score is basically the number of decision points in a routine + 1. Decision points 
	are taken to be	conditionals and loops."

	| branches loops |
	branches := #(#ifTrue: #ifFalse: #ifTrue:ifFalse: #ifFalse:ifTrue: #ifNil: #ifNil:ifNotNil: #ifNotNil:ifNil: #ifNotNil: #ifEmpty:ifNotEmpty: #ifNotEmpty:ifEmpty: #ifEmpty: #ifNotEmpty:  #at:ifAbsent: #at:ifAbsentPut: #detect:ifNone: #on:do: #and: #or: #xor:).
	loops := #(#whileTrue: #whileTrue #repeat #whileFalse #whileFalse: #timesRepeat: #to:do: #do:separatedBy: #do: #collect: #select: #reject: #inject:into: #detect: #detect:ifNone: #anySatisfy: #allSatisfy: #piecesCutWhere: #noneSatisfy:).	"-- please not that #detect:ifNone: is listed twice because it is both loop and branch!!! -- akuhn"
	(branches includes: sel) ifTrue: [ cyclomaticNumber := cyclomaticNumber + 1].
	(loops includes: sel) ifTrue: [ cyclomaticNumber := cyclomaticNumber + 1 ].
	"-- HERE STARTS THE OLD ERRORFUL IMPL --"
	
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> cyclomaticNumber [
	
	^cyclomaticNumber
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> initialize [
	
	super initialize.
	self resetMetricValues
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> methodNode: aMethod [
	methodNode := aMethod.
	self resetMetricValues.
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> processMethod: aMethodEntity [
	self methodNode: aMethodEntity.
	"(aMethodEntity methodClass parseTreeFor: aMethodEntity selector) ifNotNil: [ :parseTree |" self visitMethodNode: aMethodEntity"parseTree" "]"
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> resetMetricValues [
	cyclomaticNumber := 1.
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> visitBlockNode: aBlockNode [
	super visitBlockNode: aBlockNode.
	
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> visitCascadeNode: aCascadeNode [
	^ super visitCascadeNode: aCascadeNode
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> visitMessageNode: aMessageNode [
	| receiver selector |
	receiver := aMessageNode receiver.
	selector := aMessageNode selector.
	super visitMessageNode: aMessageNode.
	self computeCyclomaticNumber: selector.
	"(self isSuperInMethod: selector withReceiver: receiver) ifTrue: [ self methodEntity propertyNamed: #cleanSuperSend put: true ].
	(self isDirtySuperInMethod: selector withReceiver: receiver) ifTrue: [ self methodEntity propertyNamed: #dirtySuperSend put: true ]"
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> visitMethodNode: aMethodNode [
	
	" I do not know where this block came from"
	"methodComplexity := methodComplexity + (0.3 * block arguments size)."
	^ super visitMethodNode: aMethodNode
]

{ #category : #initialization }
SLVisitorForCyclomaticMetric >> visitSequenceNode: aSequenceNode [
	super visitSequenceNode: aSequenceNode.
]
