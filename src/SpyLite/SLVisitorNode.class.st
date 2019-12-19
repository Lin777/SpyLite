"
Visit any RBProgramNode in the sintax tree and evaluate literal values

    Instance Variables
	literals:		<Dictionary>
"
Class {
	#name : #SLVisitorNode,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'literals'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #initialization }
SLVisitorNode >> initialize [ 
	literals := Dictionary new
]

{ #category : #accessing }
SLVisitorNode >> literals [
	^ literals
]

{ #category : #visiting }
SLVisitorNode >> visitLiteralNode: aLiteralNode [
	| literalValue aValue |
	literalValue := aLiteralNode value.
	aValue := literals at: literalValue class name ifAbsentPut: [ Set new ].
	aValue add: literalValue
]
