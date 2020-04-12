Class {
	#name : #SLSummaryExecutionMethod,
	#superclass : #Object,
	#instVars : [
		'executorClass',
		'selector',
		'executed',
		'code',
		'summaryStatements'
	],
	#category : #'SpyLite-Utility'
}

{ #category : #'instance creation' }
SLSummaryExecutionMethod class >> on: slMethod [
	^ self new 
		executorClass: slMethod classSpy className;
		selector: slMethod selector;
		code: slMethod blocks first code;
		executed: slMethod blocks first wasExecuted;
		summaryStatements: (slMethod blocks allButFirst collect: [:block | 
			SLSummaryStatement with: block code and: block wasExecuted 	
		])
]

{ #category : #comparing }
SLSummaryExecutionMethod >> = another [ 
	^ (self class = another class) 
		and: [ (selector = another selector) 
			and: [ (executed = another executed ) 
				and: [ (executorClass = another executorClass ) 
					and: [ (summaryStatements = another summaryStatements) ] ] ] ]
]

{ #category : #accessing }
SLSummaryExecutionMethod >> code [
	^ code
]

{ #category : #accessing }
SLSummaryExecutionMethod >> code: anObject [
	code := anObject
]

{ #category : #accessing }
SLSummaryExecutionMethod >> executed [
	^ executed
]

{ #category : #accessing }
SLSummaryExecutionMethod >> executed: anObject [
	executed := anObject
]

{ #category : #accessing }
SLSummaryExecutionMethod >> executorClass [
	^ executorClass
]

{ #category : #accessing }
SLSummaryExecutionMethod >> executorClass: anObject [
	executorClass := anObject
]

{ #category : #comparing }
SLSummaryExecutionMethod >> hash [
	^ summaryStatements hash
]

{ #category : #initialization }
SLSummaryExecutionMethod >> initialize [ 	
	code := ''.
	executed := false.
	summaryStatements := OrderedCollection new
]

{ #category : #accessing }
SLSummaryExecutionMethod >> selector [
	^ selector
]

{ #category : #accessing }
SLSummaryExecutionMethod >> selector: anObject [
	selector := anObject
]

{ #category : #accessing }
SLSummaryExecutionMethod >> summaryStatements [
	^ summaryStatements
]

{ #category : #accessing }
SLSummaryExecutionMethod >> summaryStatements: anObject [
	summaryStatements := anObject
]
