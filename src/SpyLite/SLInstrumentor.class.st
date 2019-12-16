Class {
	#name : #SLInstrumentor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'blocks',
		'currentId'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #visiting }
SLInstrumentor >> addBlock: aBlockNode [
	blocks add: (self buildSBBlock: aBlockNode)
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
SLInstrumentor >> buildSBBlock: aBlockNode [
	^ SLBlock new
		id: (self nextId);
		numberOfStatements: aBlockNode body statements size;
		yourself
]

{ #category : #initialization }
SLInstrumentor >> initialize [
	super initialize.
	blocks := OrderedCollection new.
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
SLInstrumentor >> visitBlockNode: aBlockNode [
	self instrumentBlock: aBlockNode.
	super visitBlockNode: aBlockNode
]

{ #category : #visiting }
SLInstrumentor >> visitMethodNode: aMethodNode [
	self instrumentBlock: aMethodNode.
	super visitMethodNode: aMethodNode
]
