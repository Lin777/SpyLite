"
Visit any RBProgramNode in the sintax tree and evaluate literal values

    Instance Variables
	literals:		<Dictionary>
"
Class {
	#name : #SLCollectorLiteral,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'literals',
		'orderedLiterals'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #initialization }
SLCollectorLiteral >> initialize [ 
	literals := OrderedDictionary new.
	orderedLiterals := OrderedDictionary new
]

{ #category : #accessing }
SLCollectorLiteral >> literals [
	^ literals
]

{ #category : #tests }
SLCollectorLiteral >> nameOf: aClass [ 
	^ aClass name
]

{ #category : #accessing }
SLCollectorLiteral >> orderedLiterals [
	^ orderedLiterals 
]

{ #category : #visiting }
SLCollectorLiteral >> visitLiteralNode: aLiteralNode [
  | literalValue aValue valueCollection nameOfClass |
  literalValue := aLiteralNode value.
  nameOfClass := self nameOf: literalValue class.
  aValue := literals at: nameOfClass ifAbsentPut: [ Set new ].
  valueCollection := orderedLiterals at: nameOfClass ifAbsentPut: [ OrderedCollection new ].
  (aValue includes: literalValue) ifFalse: [ valueCollection add: literalValue ].
  aValue add: literalValue.
	literalValue isCollection ifTrue: [ [ aValue add: literalValue class new. valueCollection add: literalValue class new ] on: Error do: [  ] ]
]
