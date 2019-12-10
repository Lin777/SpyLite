"
I obtain runtime information by profiling the execution of a block of Smalltalk code.

I offer a number of public class methods to interface with the profiling.

profile: aBlock inPackagesNamed: packageNames accepts as first parameter a block and as second parameter a collection of package names.

The effect of calling this method is to
(i) instrument the specified packages;
(ii) execute the provided block;
(iii) uninstrument the targeted packages; and
(iv) return the collected data in the form of an instance of the Profiler class which contains instances of PackageSpy, ClassSpy and MethodSpy, essentially mirroring the structure of the program.
"
Class {
	#name : #SLProfiler,
	#superclass : #SpyLite,
	#instVars : [
		'packages',
		'totalExecutionTime',
		'allClassesAsDictionaryCache',
		'allMethodsCache',
		'counter',
		'unitTestResult',
		'packagesToTest',
		'allNonAbstractMethodsCache'
	],
	#category : #'SpyLite-MetaModel'
}

{ #category : #gathering }
SLProfiler class >> allSpysForPackagesMatching: regexpAsString [
	"
	self allSpysForPackagesMatching: 'Mondrian*'.
	"
	| classes answer |
	classes := self classesForPackagesMatching: regexpAsString.
	answer := OrderedCollection new.
	classes do: [:cls | answer addAll: (cls methods select: #isSpy)].
	^ answer
]

{ #category : #gathering }
SLProfiler class >> classesAndMetaClassesFor: aPackage [ 
	^ OrderedCollection new
		addAll: aPackage definedClasses;
		addAll: (aPackage definedClasses collect: [ :each | each classSide ]);
		yourself
]

{ #category : #gathering }
SLProfiler class >> classesForPackagesMatching: regexpAsString [
	"Return the list of classes defines in the packages matching one of the regular expressions"
	"Traits are excluded"

	| packages classes |
	packages := (RPackageOrganizer default packages select: [:p | regexpAsString match: p name asString ]).
	classes := packages inject: #() 
						into: [:sum :el | sum, (el classes reject: #isTrait) asOrderedCollection ].
	^ classes
]

{ #category : #util }
SLProfiler class >> currentTestCase [ 
	^ currentTestCase


]

{ #category : #util }
SLProfiler class >> currentTestCase: aTestCase [
	^ currentTestCase := aTestCase

]

{ #category : #util }
SLProfiler class >> currentTestMethod [ 
	^ currentTestMethod


]

{ #category : #util }
SLProfiler class >> currentTestMethod: aSelector [ 
	^ currentTestMethod := aSelector


]

{ #category : #util }
SLProfiler class >> currentTestMethodSpy: aSelector [ 
	^ currentTestMethodSpy := aSelector


]

{ #category : #hooks }
SLProfiler class >> defaultRun [
	"Tell on what the profiler has to be run per default"
	^ #package 
]

{ #category : #'public - profiling' }
SLProfiler class >> evaluateBlock: aBlock [
	aBlock value.
]

{ #category : #'public - installing removing' }
SLProfiler class >> forClass: aClass [
	| profiler classSpy packageSpy |
	self installOnClass: aClass.
	profiler := self new.
	classSpy := profiler spyForClass: aClass.
	packageSpy := self spyClassForPackage new.
	packageSpy classAt: aClass name put: classSpy.
	classSpy packageSpy:  packageSpy.
	packageSpy packageName: 'Smalltalk'.
	profiler addPackage: packageSpy.
	
	^ profiler
]

{ #category : #gathering }
SLProfiler class >> gather [

	^ self new gather
]

{ #category : #gathering }
SLProfiler class >> gatherForClassCategory: nameAsString [
	"Return a profiler"
	^ self new gatherForClassCategory: nameAsString 
]

{ #category : #gathering }
SLProfiler class >> gatherForPackageNamed: nameAsString [
	"Return a profiler"
	
	^ self new gatherForPackageNamed: nameAsString 
]

{ #category : #gathering }
SLProfiler class >> gatherForPackagesMatching: regexpAsString [
	"Return a profiler"
	
	^ self new gatherForPackagesMatching: regexpAsString
]

{ #category : #gathering }
SLProfiler class >> gatherForSeveralPackagesMatching: collectionOfRegExp [
	"Return a profiler"
	
	^ self new gatherForSeveralPackagesMatching: collectionOfRegExp
]

{ #category : #'private - method template' }
SLProfiler class >> generateTemplates [
	"
	self generateTemplates
	"
	| argString parameterString |
	self class compileSilently: 'with0Arg ', String cr, (self templateCode expandMacrosWith: '#()') classified: 'private - method template'.
	1 to: 15 do: [ :i |
		parameterString := ''.
		argString := '{'.
		1 to: i do: [ :ii | 
			parameterString := parameterString, 'arg: ', 'v', ii printString, ' '.
			argString := argString, 'v', ii printString, '.'].
		
		argString := argString allButLast, '}'.

		self class 
				compile: 'with', i printString, parameterString, String cr, (self templateCode expandMacrosWith: argString)
				classified: 'private - method template'.
	]
]

{ #category : #'private - installing' }
SLProfiler class >> install [
	" Install on all classes"
	self installOnClasses: Smalltalk allClasses
]

{ #category : #'private - installing' }
SLProfiler class >> installOnBehavior: aBehavior [
	| dict cm templateMethod metaObject |

	aBehavior flushCache.
	
	"We do nothing for traits"
	aBehavior isTrait ifTrue: [ ^ self ].

	dict := aBehavior methodDict.
	dict keys do:
		[:k|
			k flushCache.
			cm := dict at: k.
			cm isSpy ifFalse: [
				"Using template method"
				templateMethod := self templateMethodForNumberOfArguments: cm 	numArgs.
				templateMethod := templateMethod copyFor: aBehavior.
				metaObject := self spyClassForMethod new 
										originalMethod: cm; 
										selector: k; 
										instrumentedMethod: templateMethod;
										yourself.
				templateMethod replaceLiterals: 
					{templateMethod selector -> k . 
					 #metaObject -> metaObject . 
					 #selector -> k}.
				dict at: k put: templateMethod.]
			
			"Using method wrapper"
"			(cm isCompiledMethod and: [ self shouldInstallOnCompiledMethod: cm])
			 	ifTrue: [dict at: k put: (self spyClassForMethod new originalMethod: cm; selector: k; yourself)]
"		]
			
]

{ #category : #'private - installing' }
SLProfiler class >> installOnClass: aClass [
	"Transcript show: 'instrumenting ', aClass name printString ;cr."

	(self isDangerous: aClass instanceSide)
		ifTrue: [ ^ self ].
	self
		installOnBehavior: aClass instanceSide;
		installOnBehavior: aClass classSide.
	^ self new spyForClass: aClass
]

{ #category : #'private - installing' }
SLProfiler class >> installOnClassCategory: nameAsString [
	| classNames classesAndTraits classes |
	classNames := SystemOrganization listAtCategoryNamed: nameAsString.
	classesAndTraits := classNames collect: [:clsName | Smalltalk at: clsName].
	classes := classesAndTraits reject: #isTrait.

	self installOnClasses: classes
]

{ #category : #'private - installing' }
SLProfiler class >> installOnClassCategoryMatching: regexpAsString [
	(SystemOrganization categoriesMatching: regexpAsString)
		do: [:cat | self installOnClassCategory: cat]
]

{ #category : #'private - installing' }
SLProfiler class >> installOnClasses: classes [
	classes do: [:cls | self installOnClass: cls ].

]

{ #category : #'private - installing' }
SLProfiler class >> installOnPackagesMatching: regexpAsString [

	| classes |
	classes := self classesForPackagesMatching: regexpAsString.
	classes do: [:cls | self installOnClass: cls ]
]

{ #category : #util }
SLProfiler class >> isDangerous: aClass [
	self
		assert: [ aClass instanceSide == aClass ]
		description: 'Can only be called on non meta class'.
	"	(aClass inheritsFrom: Spy) ifTrue: [ ^ true ].
	true ifTrue: [ ^ false ].	"

	"Cannot instrument a configuration"
	(aClass name beginsWith: 'ConfigurationOf')
		ifTrue: [ ^ true ].

	"Can instrument the scenario example, even it belongs to Spy"
	(aClass category beginsWith: 'Spy-ScenarioExample')
		ifTrue: [ ^ false ].

	"	({ByteSymbol . String . Symbol . MethodReference . MorphicToolBuilder} includes: aClass)
		ifTrue: [ ^ true ]."
	(#('Spy-Core' 'Announcements' 'Balloon' 'Collections' 'CollectionsTests' 'Compiler' 'CompilerTests' 'Compression' 'DeprecatedPreferences' 'Exceptions' 'Files' 'FixUnderscores' 'FreeType' 'FreeTypeSubPixelAntiAliasing' 'FreeTypeTests' 'Gofer' 'Graphics' 'GraphicsTests' 'HostMenus' 'Kernel' 'KernelTests' 'MCDirtyPackage' 'MenuRegistration' 'Monticello' 'MonticelloConfigurations' 'MonticelloGUI' 'MonticelloMocks' 'Morphic' 'MorphicTests' 'Multilingual' 'MultilingualTests' 'ObjectMetaTools' 'PackageInfo' 'PinesoftEnhancementsForFreetype' 'Polymorph' 'PreferenceBrowser' 'ST80' 'SUnit' 'SUnitGUI' 'ScriptLoader' 'ScriptLoader11' 'Settings' 'System' 'Tests' 'ToolBuilder' 'Tools' 'ToolsTest' 'Traits' 'TrueType' 'VB')
		anySatisfy: [ :cat | aClass category beginsWith: cat ])
		ifTrue: [ ^ true ].
	"'Network' 'NetworkTests' "
	^ false
	"	^ aClass isCollection
		or: [ ((Smalltalk specialObjectsArray select: #isBehavior) includes: aClass) ]
"
]

{ #category : #util }
SLProfiler class >> isNotDangerous: aClass [
	^ (self isDangerous: aClass) not
]

{ #category : #util }
SLProfiler class >> log: aString [
	Transcript show: 'Running: ', aString asString; cr.
]

{ #category : #util }
SLProfiler class >> nonDangerousClasses [
	^ Smalltalk allClasses select: [:cls | SLProfiler isNotDangerous: cls ]
]

{ #category : #util }
SLProfiler class >> packageInfosMatching: regexpAsString [
	"Return the list of package info for which their names match the argument
	
	Profiler packageInfosMatching: 'Kernel*'
	"
	
	^ MCWorkingCopy allManagers  select: [:p | regexpAsString match: p package name]
]

{ #category : #util }
SLProfiler class >> packageNamesMatching: regexpAsString [
	"Return the list of package names for which their names match the argument
	
	Profiler packageNamesMatching: 'Kern*'
	"
	
	^ (self packageInfosMatching: regexpAsString) collect: #packageName
]

{ #category : #'public - profiling' }
SLProfiler class >> profile: aBlock [

	| profiler messageTally tally |
	self 
		assert: [ self new getTimeAndCallGraph ] 
		description: 'profile: can be invoked only if getTimeAndCallGraph return true'.
	
	profiler := self new.
	'Profiling' displayProgressAt: Display center from:1 to: 5 during: [:bar |
		bar value: 1.
		tally := (profiler tallyOn: aBlock).
		Smalltalk garbageCollect.
		[  bar value: 2.
			"self installOnClasses: tally allInvolvedClasses."
			self installOnPackagesNamed: tally allInvolvedPackageNames.
			profiler beforeProfiling.
			bar value: 3.
			aBlock value.

			bar value: 4.
			profiler gatherForPackagesNamed: tally allInvolvedPackageNames.
			profiler afterProfiling ]
		ensure: [ self removeFromPackagesNamed:  tally allInvolvedPackageNames ].

		bar value: 5.
		profiler setTimeInfoFromTally: tally.
		tally close ].

	^ profiler
]

{ #category : #'public - profiling' }
SLProfiler class >> profile: aBlock forClassNamed: className [

	|profiler packageSpy cls classSpy |
	cls := Smalltalk at: className.
	profiler := self new.
	Transcript show: 'profiling...'; cr.
	[
		self installOnClass: cls.
		profiler beforeProfiling.
		
		classSpy := profiler spyForClass: cls.
		packageSpy := self spyClassForPackage new.
		packageSpy classAt: className put: classSpy.
		profiler addPackage: packageSpy.
		classSpy packageSpy: packageSpy.
		aBlock value.
		profiler afterProfiling. ]
	ensure: [ self removeFromClass: cls ].
	Transcript show: 'ended...'; cr.
	^ profiler
]

{ #category : #'public - profiling' }
SLProfiler class >> profile: aBlock inClassCategory: classCategory [

	| profiler |
	
	Transcript show: 'profiling...'; cr.
	profiler := self new.
	[
		self installOnClassCategory: classCategory.
		profiler beforeProfiling.
		profiler := self gatherForClassCategory: classCategory.
		self evaluateBlock: aBlock.
		profiler afterProfiling ]
	ensure: [ self removeFromClassCategory: classCategory ].
	Transcript show: 'ended...'; cr.
	profiler setIfNecessaryTimeAndCallGraphFrom: aBlock.
	profiler checkInvariant.
	^ profiler
]

{ #category : #'public - profiling' }
SLProfiler class >> profile: aBlock inPackage: packageName [

	|profiler |
	Transcript show: 'profiling...'; cr.
	[
		self installOnPackageNamed: packageName.
		profiler := self gatherForPackageNamed: packageName.
		profiler beforeProfiling.
		aBlock value.
		profiler afterProfiling. ]
	ensure: [ self removeFromPackageNamed: packageName ].
	Transcript show: 'ended...'; cr.
	profiler setIfNecessaryTimeAndCallGraphFrom: aBlock.
	profiler checkInvariant.
	
	^ profiler
]

{ #category : #'public - profiling' }
SLProfiler class >> profile: aBlock inPackagesMatching: regexp [

	| profiler |
	
	Transcript show: 'profiling...'; cr.
	[
		self installOnPackagesMatching: regexp.
		profiler := self gatherForPackagesMatching: regexp.
		profiler beforeProfiling.
		aBlock value.
		
		profiler afterProfiling  ]
	ensure: [ self removeFromPackagesMatching: regexp ].
	Transcript show: 'ended...'; cr.
	profiler checkInvariant.
	^ profiler
]

{ #category : #'public - profiling' }
SLProfiler class >> profile: aBlock inSeveralPackagesMatching: collectionOfRegExp [

	| profiler |
	
	Transcript show: 'profiling...'; cr.
	[
		collectionOfRegExp do: [ :regexp |
			self installOnPackagesMatching: regexp ].
		
		"A bit awkward. Hopefully with Spy2 this will be removed"
		profiler := self gatherForSeveralPackagesMatching: collectionOfRegExp.
		profiler beforeProfiling.
		aBlock value.
		
		profiler afterProfiling  ]
	ensure: [ collectionOfRegExp do: [ :regexp | self removeFromPackagesMatching: regexp ] ].
	Transcript show: 'ended...'; cr.
	profiler setIfNecessaryTimeAndCallGraphFrom: aBlock.
	profiler checkInvariant.
	^ profiler
]

{ #category : #'private - installing' }
SLProfiler class >> remove [
	" Install on all classes"
	self removeFromClasses: Smalltalk allClasses
]

{ #category : #'private - installing' }
SLProfiler class >> removeFrom: class [
	class flushCache.
	class selectors do: [:k | k flushCache ].
	class removeSpys
]

{ #category : #'private - installing' }
SLProfiler class >> removeFromClass: class [
	SLProfiler class == class ifTrue: [ ^ self ].
	^ self removeFrom: class
]

{ #category : #'private - installing' }
SLProfiler class >> removeFromClassCategory: nameAsString [
	| classNames classesAndTraits classes |
	classNames := SystemOrganization listAtCategoryNamed: nameAsString.
	classesAndTraits := classNames collect: [:clsName | Smalltalk at: clsName].
	classes := classesAndTraits reject: #isTrait.
	self removeFromClasses: ((classes collect: #theNonMetaClass), (classes collect: #theMetaClass))

]

{ #category : #'private - installing' }
SLProfiler class >> removeFromClassCategoryMatching: regexpAsString [
	(SystemOrganization categoriesMatching: regexpAsString)
		do: [:cat | self removeFromClassCategory: cat]
]

{ #category : #'private - installing' }
SLProfiler class >> removeFromClasses: classes [
	^ classes do: [:cls | self 
							removeFromClass: cls theNonMetaClass;
							removeFromClass: cls theMetaClass ].
]

{ #category : #'private - installing' }
SLProfiler class >> removeFromPackagesMatching: regexpAsString [
	| classes |
	classes := self classesForPackagesMatching: regexpAsString.
	classes do: [:cls | cls removeSpys ]
	
]

{ #category : #'private - installing' }
SLProfiler class >> removeFromPackagesNamed: strings [
	self assert: [ strings isString not ] description: 'A collection of String must be passed to #removeFromPackagesNamed:'.
	self assert: [ (strings allSatisfy: #isString) ] description: 'A collection of must should be passed to #removeFromPackagesNamed:'.

	strings do: [ :packageName | self removeFromPackageNamed: packageName ]
	
]

{ #category : #util }
SLProfiler class >> shouldInstallOnClass: aClass [

	self assert: [ aClass theNonMetaClass == aClass ] description: 'Can only be called on non meta class'.
	
	^ (self isNotDangerous: aClass)
]

{ #category : #util }
SLProfiler class >> shouldInstallOnCompiledMethod: compiledMethod [
	^ (compiledMethod pragmaAt: #nospy) isNil
]

{ #category : #hooks }
SLProfiler class >> spyClassForClass [
	^ self spyClassForPackage spyClassForClass
]

{ #category : #hooks }
SLProfiler class >> spyClassForMethod [
	^ self spyClassForPackage spyClassForClass spyClassForMethod
]

{ #category : #hooks }
SLProfiler class >> spyClassForPackage [
	^ SLPackage
]

{ #category : #'private - method template' }
SLProfiler class >> templateCode [
	^ '^ #metaObject run: #selector with: <1s> in: self  '
		
"	^ '^ MethodSpy isInMeta
		ifTrue: [ #metaObject originalMethod valueWithReceiver: self arguments: <1s> ]
		ifFalse: [ #metaObject run: #selector with: <1s> in: self ] '"
]

{ #category : #'private - method template' }
SLProfiler class >> templateMethodForNumberOfArguments: numberOfArguments [
	^ SLProfiler class>> (#(
			#with0Arg
			#with1arg:
			#with2arg:arg:
			#with3arg:arg:arg:
			#with4arg:arg:arg:arg:
			#with5arg:arg:arg:arg:arg:
			#with6arg:arg:arg:arg:arg:arg:
			#with7arg:arg:arg:arg:arg:arg:arg:
			#with8arg:arg:arg:arg:arg:arg:arg:arg:
			#with9arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with10arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with11arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with12arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with13arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with14arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with15arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			) at: (numberOfArguments + 1))
]

{ #category : #'private - method template' }
SLProfiler class >> templateMethods [
	^ #(
			#with0Arg
			#with1arg:
			#with2arg:arg:
			#with3arg:arg:arg:
			#with4arg:arg:arg:arg:
			#with5arg:arg:arg:arg:arg:
			#with6arg:arg:arg:arg:arg:arg:
			#with7arg:arg:arg:arg:arg:arg:arg:
			#with8arg:arg:arg:arg:arg:arg:arg:arg:
			#with9arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with10arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with11arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with12arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with13arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with14arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			#with15arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:arg:
			) collect: [:k | self class >> k ]
]

{ #category : #hooks }
SLProfiler class >> testMethodsToIgnore [
	"This is intended to be temporary. There are some strange bugs that are hard to track down"
	^ #(testNestingOfFormBuilder testNestedCycle)
]

{ #category : #'public - profiling' }
SLProfiler class >> viewProfiling: aBlock [

	(self profile: aBlock) visualize 
]

{ #category : #'public - profiling' }
SLProfiler class >> viewProfiling: aBlock inPackage: packageName [

	(self profile: aBlock inPackage: packageName) visualize
]

{ #category : #'public - profiling' }
SLProfiler class >> viewProfiling: aBlock inPackagesMatching: regexp [

	(self profile: aBlock inPackagesMatching: regexp) visualize
]

{ #category : #'private - method template' }
SLProfiler class >> with0Arg [
	^ #metaObject
		run: #selector
		with: #()
		in: self
]

{ #category : #'private - method template' }
SLProfiler class >> with10arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 arg: v6 arg: v7 arg: v8 arg: v9 arg: v10 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5.v6.v7.v8.v9.v10} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with11arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 arg: v6 arg: v7 arg: v8 arg: v9 arg: v10 arg: v11 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5.v6.v7.v8.v9.v10.v11} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with12arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 arg: v6 arg: v7 arg: v8 arg: v9 arg: v10 arg: v11 arg: v12 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5.v6.v7.v8.v9.v10.v11.v12} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with13arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 arg: v6 arg: v7 arg: v8 arg: v9 arg: v10 arg: v11 arg: v12 arg: v13 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5.v6.v7.v8.v9.v10.v11.v12.v13} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with14arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 arg: v6 arg: v7 arg: v8 arg: v9 arg: v10 arg: v11 arg: v12 arg: v13 arg: v14 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5.v6.v7.v8.v9.v10.v11.v12.v13.v14} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with15arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 arg: v6 arg: v7 arg: v8 arg: v9 arg: v10 arg: v11 arg: v12 arg: v13 arg: v14 arg: v15 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5.v6.v7.v8.v9.v10.v11.v12.v13.v14.v15} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with1arg: v1 [ 
^ #metaObject run: #selector with: {v1} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with2arg: v1 arg: v2 [ 
^ #metaObject run: #selector with: {v1.v2} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with3arg: v1 arg: v2 arg: v3 [ 
^ #metaObject run: #selector with: {v1.v2.v3} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with4arg: v1 arg: v2 arg: v3 arg: v4 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with5arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with6arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 arg: v6 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5.v6} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with7arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 arg: v6 arg: v7 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5.v6.v7} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with8arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 arg: v6 arg: v7 arg: v8 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5.v6.v7.v8} in: self  
]

{ #category : #'private - method template' }
SLProfiler class >> with9arg: v1 arg: v2 arg: v3 arg: v4 arg: v5 arg: v6 arg: v7 arg: v8 arg: v9 [ 
^ #metaObject run: #selector with: {v1.v2.v3.v4.v5.v6.v7.v8.v9} in: self  
]

{ #category : #'accessing - read only' }
SLProfiler >> >> aSymbol [
	"Fetching a class"
	
	"we are accessing a method defined in a metaclass"
	(aSymbol includes: $ ) ifTrue: [ ^ (self >> aSymbol substrings first asSymbol) metaclassSpy ].
	
	^ self classAt: aSymbol
]

{ #category : #'accessing - read only' }
SLProfiler >> >>> aPackageName [
	^ self packages detect: [:pak | pak packageName asString = aPackageName asString ]
]

{ #category : #adding }
SLProfiler >> addPackage: aPackageSpy [
	self assert: [ aPackageSpy class == self class spyClassForPackage ].
	
	self packages add: aPackageSpy.
	aPackageSpy profiler: self.
]

{ #category : #hooks }
SLProfiler >> afterProfiling [ 

]

{ #category : #'accessing - read only' }
SLProfiler >> allClasses [
	| answer |
	answer := OrderedCollection new.
	self packages do: [:p | 
		answer addAll: p classes ].
	^ answer
]

{ #category : #'accessing - read only' }
SLProfiler >> allClassesAsDictionary [
	| answer |
	allClassesAsDictionaryCache ifNotNil: [ ^ allClassesAsDictionaryCache ].
	answer := Dictionary new.
	self packages do: [:p | p classes do: [:c | answer at: c className put: c]].
	^ allClassesAsDictionaryCache := answer
]

{ #category : #'accessing - read only' }
SLProfiler >> allClassesSuchThat: aBlock [
	^ self allClasses select: aBlock
]

{ #category : #'accessing - read only' }
SLProfiler >> allMethods [
	"Return the list of all the methods"
	
	allMethodsCache ifNotNil: [ ^ allMethodsCache ].
	
	allMethodsCache := OrderedCollection new.
	self packages do: [:p | 
		allMethodsCache addAll: p allMethods ].
	^ allMethodsCache 
]

{ #category : #'accessing - read only' }
SLProfiler >> allNonAbstractMethods [
	"Return the list of non abstract methods"
	
	allNonAbstractMethodsCache ifNotNil: [ ^ allNonAbstractMethodsCache ].
	^ allNonAbstractMethodsCache := self allMethods reject: #isAbstract
]

{ #category : #'accessing - read only' }
SLProfiler >> allNonMetaClasses [
	^ self allClasses reject: #isMeta
]

{ #category : #hooks }
SLProfiler >> beforeProfiling [ 
	SLMethod setInNonMeta
]

{ #category : #contract }
SLProfiler >> checkInvariant [
	self assert: [ self packages notNil ].
	self assert: [ self packages allSatisfy: [ :p | p isKindOf: self class spyClassForPackage ] ].
	self assert: [ self packages allSatisfy: [ :p | p profiler notNil ]].
	self assert: [ self packages allSatisfy: [ :p | p profiler == self ]].

	self packages do: #checkInvariant.
]

{ #category : #'accessing - read only' }
SLProfiler >> classAt: aSymbol [
	^ self allClassesAsDictionary at: aSymbol ifAbsent: [ self error: 'Class ', aSymbol, ' not found']
]

{ #category : #'accessing - read only' }
SLProfiler >> classAt: aSymbol ifNone: aBlock [
	^ self allClassesAsDictionary at: aSymbol ifAbsent: aBlock
	
]

{ #category : #gathering }
SLProfiler >> classesAndMetaClassesFor: aPackage [ 
	^ self class classesAndMetaClassesFor: aPackage.
]

{ #category : #gathering }
SLProfiler >> fillClassType: classType with: methodDictionary [
	| compiledMethod methodSpy |
	classType theClass == SLProfiler class
		ifTrue: [ ^ self ].
	
	methodDictionary associationsDo: 
		[:assoc | 
			compiledMethod := (classType theClass >> assoc key).
			compiledMethod isSpy
				ifTrue: [ methodSpy := compiledMethod methodSpy.
							methodSpy classSpy: classType.
							classType localMethodAt: assoc key put: methodSpy ] ].

]

{ #category : #gathering }
SLProfiler >> gather [

	^ self gatherForClasses: self class nonDangerousClasses.

]

{ #category : #gathering }
SLProfiler >> gatherForClassCategory: nameAsString [
	"Return a profiler"
	| package|
	package := self packageForClassCategory: nameAsString.
	package packageName: nameAsString.

	self addPackage: package.

	^ self
]

{ #category : #gathering }
SLProfiler >> gatherForClasses: classes [

	| package classType |
	package := self class spyClassForPackage new.
	package packageName: 'Global profiling'.

	classes do: [:cls |
		classType := self spyForClass: cls.
		classType packageSpy: package.
		package classAt: cls name put: classType].
	
	self addPackage: package.
	^ package
]

{ #category : #gathering }
SLProfiler >> gatherForPackagesMatching: regexpAsString [
	"Return a profiler"
	
	| tpackages |

	tpackages := (RPackageOrganizer default packages select: [:p | regexpAsString match: p name asString ]).

	tpackages do: [ :pak | 
		| class package |
		package := self class spyClassForPackage new.
		package packageName: pak packageName.
		self addPackage: package.

		((self classesAndMetaClassesFor: pak) reject: #isTrait) do: [:cls|
			class := self spyForClass: cls.
			class packageSpy: package.
			package classAt: cls name asSymbol put: class ] ].

	^ self
]

{ #category : #gathering }
SLProfiler >> gatherForSeveralPackagesMatching: collectionOfRegExp [
	"Return a profiler"
	
	| tpackages |
	collectionOfRegExp do: [ :regexpAsString | 
		tpackages := (RPackageOrganizer default packages select: [:p | regexpAsString match: p name asString ]).

		tpackages do: [ :pak | 
			| class package |
			package := self class spyClassForPackage new.
			package packageName: pak packageName.
			self addPackage: package.

			((self classesAndMetaClassesFor: pak) reject: #isTrait) do: [:cls|
				class := self spyForClass: cls.
				class packageSpy: package.
				package classAt: cls name asSymbol put: class ] ] ].

	^ self
]

{ #category : #testing }
SLProfiler >> hasUnitTestResult [
	^ unitTestResult notNil
]

{ #category : #'initialize-release' }
SLProfiler >> initialize [ 
	super initialize.
	packages := nil.
	
]

{ #category : #installing }
SLProfiler >> install [
	self allMethods asSet do: #install
]

{ #category : #'accessing - read only' }
SLProfiler >> noncoveredMethods [ 
	"Return the list of noncovered methods"

	^ self allMethods reject: #isCovered
]

{ #category : #'accessing - read only' }
SLProfiler >> numberOfClasses [
	^ self allClasses size
]

{ #category : #'accessing - read only' }
SLProfiler >> numberOfMethods [
	^ self allMethods size
]

{ #category : #'accessing - read only' }
SLProfiler >> numberOfNonAbstractMethods [
	"Return the number of non abstract methods, including the one of the metaclass "

	^ self allNonAbstractMethods size
]

{ #category : #gathering }
SLProfiler >> packageForClassCategory: nameAsString [
	| package classNames classType |
	package := self class spyClassForPackage new.

	classNames := SystemOrganization listAtCategoryNamed: nameAsString.
	
	classNames do: [:clsName |
		| cls |
		cls := Smalltalk at: clsName.
		cls isTrait ifFalse: 
			[classType := self spyForClass: cls.
			classType packageSpy: package.
			package classAt: clsName put: classType]].
	
	^ package
]

{ #category : #accessing }
SLProfiler >> packages [
	^ packages ifNil: [ packages := OrderedCollection new ]
]

{ #category : #accessing }
SLProfiler >> packagesToTest: aCollectionOfStrings [
	packagesToTest := aCollectionOfStrings
]

{ #category : #actions }
SLProfiler >> remove [
	^ self class remove
]

{ #category : #actions }
SLProfiler >> removeFromRegistry [
	self class registry removeKey: (self class registry keyAtValue: self )
]

{ #category : #gathering }
SLProfiler >> spyForClass: aClass [
	| classType |
	classType := self class spyClassForClass new.
	classType className: aClass name.
	self fillClassType: classType with: aClass methodDict.
	self fillClassType: classType metaclassSpy with: aClass class methodDict.
	^ classType

]

{ #category : #installing }
SLProfiler >> uninstall [
	self allMethods do: #uninstall
]

{ #category : #accessing }
SLProfiler >> unitTestResult [
	^ unitTestResult
]

{ #category : #accessing }
SLProfiler >> unitTestResult: testResult [
	unitTestResult := testResult
]
