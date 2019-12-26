"
Visit any RBProgramNode in the sintax tree and evaluate literal values

    Instance Variables
	literals:		<Dictionary>
"
Class {
	#name : #SLCollectLiteral,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'literals'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #initialization }
SLCollectLiteral >> initialize [ 
	literals := Dictionary new
]

{ #category : #accessing }
SLCollectLiteral >> literals [
	^ literals
]

{ #category : #visiting }
SLCollectLiteral >> visitLiteralNode: aLiteralNode [
	| literalValue aValue |
	literalValue := aLiteralNode value.
	aValue := literals at: literalValue class name ifAbsentPut: [ Set new ].
	aValue add: literalValue
]
