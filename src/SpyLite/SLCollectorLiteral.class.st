"
Visit any RBProgramNode in the sintax tree and evaluate literal values

    Instance Variables
	literals:		<Dictionary>
"
Class {
	#name : #SLCollectorLiteral,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'literals'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #initialization }
SLCollectorLiteral >> initialize [ 
	literals := Dictionary new
]

{ #category : #accessing }
SLCollectorLiteral >> literals [
	^ literals
]

{ #category : #visiting }
SLCollectorLiteral >> visitLiteralNode: aLiteralNode [
	| literalValue aValue |
	literalValue := aLiteralNode value.
	aValue := literals at: literalValue class name ifAbsentPut: [ Set new ].
	aValue add: literalValue
]
