Class {
	#name : #SLClassCoverage,
	#superclass : #SLClass,
	#category : #'SpyLite-MetaModel'
}

{ #category : #hooks }
SLClassCoverage class >> spyClassForMethod [
	^ SLMethodCoverage
]
