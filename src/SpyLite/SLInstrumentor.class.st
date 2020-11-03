Class {
	#name : #SLInstrumentor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'blocks',
		'currentId',
		'currentReturn'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #visiting }
SLInstrumentor >> addBlock: aBlockNode [
	blocks add: (self buildSBBlock: aBlockNode)
]

{ #category : #visiting }
SLInstrumentor >> addPathNode: aMethodNode [
	aMethodNode body addNodeLast: (self buildPathNode)
]

{ #category : #accessing }
SLInstrumentor >> blocks [ 	
	^ blocks
]

{ #category : #visiting }
SLInstrumentor >> buildGhostNode: anInteger [
	^ RBParser parseExpression: '#metaObject count: ' , anInteger asString , '.nil.'.
]

{ #category : #visiting }
SLInstrumentor >> buildPathNode [
	^ RBParser parseExpression: '#metaObject addPath: #metaObject executedPath; cleanBlocks. nil.'.
]

{ #category : #visiting }
SLInstrumentor >> buildSBBlock: aBlockNode [
	^ SLBlock new
		id: (self nextId);
		numberOfStatements: aBlockNode body statements size;
		code: aBlockNode sourceCode;
		yourself
]

{ #category : #initialization }
SLInstrumentor >> initialize [
	super initialize.
	blocks := OrderedCollection new.
	currentReturn := 0.
]

{ #category : #visiting }
SLInstrumentor >> instrumentBlock: aBlockNode [
	self addBlock: aBlockNode.
	aBlockNode body addNodeFirst: (self buildGhostNode: currentId)
]

{ #category : #visiting }
SLInstrumentor >> nextId [
	currentId := blocks size + 1.
	^ currentId.
]

{ #category : #visiting }
SLInstrumentor >> nextReturn [
	currentReturn := currentReturn + 1.
	^ currentReturn.
]

{ #category : #visiting }
SLInstrumentor >> visitBlockNode: aBlockNode [
	self instrumentBlock: aBlockNode.
	super visitBlockNode: aBlockNode
]

{ #category : #visiting }
SLInstrumentor >> visitMethodNode: aMethodNode [
	self instrumentBlock: aMethodNode.
	super visitMethodNode: aMethodNode.
	aMethodNode body lastIsReturn ifFalse: [ self addPathNode: aMethodNode ].
]

{ #category : #visiting }
SLInstrumentor >> visitReturnNode: aReturnNode [
	(aReturnNode value isVariable or: [ aReturnNode value isLiteralNode ]) 
		ifFalse: [ |temp|
			temp := '_returnValue', self nextReturn asString.
			aReturnNode parent addTemporaryNamed: temp.
			aReturnNode parent addNodeLast: (RBAssignmentNode 
				variable:  (RBVariableNode named: temp) 
				value: aReturnNode value).
			aReturnNode value: (RBVariableNode named: temp)  ].
	aReturnNode parent addNodeLast: (self buildPathNode).
	super visitReturnNode: aReturnNode.
]
