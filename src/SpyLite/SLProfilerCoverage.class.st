Class {
	#name : #SLProfilerCoverage,
	#superclass : #SLProfiler,
	#category : #'SpyLite-MetaModel'
}

{ #category : #hooks }
SLProfilerCoverage class >> spyClassForPackage [
	^ SLPackageCoverage
]

{ #category : #hooks }
SLProfilerCoverage >> beforeProfiling [
	self allMethods select: #isNotMethodExtension thenDo: #installGhosts.
]
