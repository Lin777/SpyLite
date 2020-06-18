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
	literals := OrderedDictionary new
]

{ #category : #accessing }
SLCollectorLiteral >> literals [
	^ literals
]

{ #category : #tests }
SLCollectorLiteral >> nameOf: aClass [ 
	^ aClass name
]

{ #category : #visiting }
SLCollectorLiteral >> visitLiteralNode: aLiteralNode [
  | literalValue aValue |
  literalValue := aLiteralNode value.
  aValue := literals at: (self nameOf: literalValue class) ifAbsentPut: [ OrderedSet new ].
  aValue add: literalValue.
	literalValue isCollection ifTrue: [ [ aValue add: literalValue class new ] on: Error do: [  ] ]
]
