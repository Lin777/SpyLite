Class {
	#name : #SLPackageCoverage,
	#superclass : #SLPackage,
	#category : #'SpyLite-MetaModel'
}

{ #category : #hooks }
SLPackageCoverage class >> spyClassForClass [
	^ SLClassCoverage
]
