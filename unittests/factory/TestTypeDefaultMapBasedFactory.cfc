<cfcomponent extends="mxunit.framework.TestCase">

<cfset variables.System = createObject("java", "java.lang.System") />

<cffunction name="testCreateByTypeName" returntype="void" access="public">
	<cfset var fac = createObject("component", "ModelGlue.gesture.factory.TypeDefaultingMapBasedFactory").init() />
	<cfset var inst = fac.create("unittests.factory.ImplOne") />

	<cfset assertTrue(getMetadata(inst).name eq "unittests.factory.ImplOne", "correct type not instantiated") />	
</cffunction>

<cffunction name="testCreateByAlias" returntype="void" access="public">
	<cfset var fac = createObject("component", "ModelGlue.gesture.factory.TypeDefaultingMapBasedFactory") />
	<cfset var map = structNew() />
	<cfset var inst1 = ""/>
	<cfset var inst2 = ""/>

	<cfset map.implOne = {class="unittests.factory.ImplOne"} />
	<cfset map.implTwo = {class="unittests.factory.ImplTwo"} />
	
	<cfset fac.init(map) />
	
	<cfset inst1 = fac.create("implOne") />
	<cfset inst2 = fac.create("implTwo") />
	
	<cfset assertTrue(getMetadata(inst1).name eq "unittests.factory.ImplOne", "correct type not instantiated") />	
	<cfset assertTrue(getMetadata(inst2).name eq "unittests.factory.ImplTwo", "correct type not instantiated") />	
</cffunction>

<cffunction name="testSingleton" returntype="void" access="public">
	<cfset var fac = createObject("component", "ModelGlue.gesture.factory.TypeDefaultingMapBasedFactory").init() />
	<cfset var inst1 = fac.create("unittests.factory.ImplOne") />
	<cfset var inst2 = fac.create("unittests.factory.ImplOne") />

	<cfset assertTrue(System.identityHashCode(inst1) eq System.identityHashCode(inst2), "Two refs should be same instance!") />	
</cffunction>

<cffunction name="testConstructorArgs" returntype="void" access="public">
	<cfset var fac = createObject("component", "ModelGlue.gesture.factory.TypeDefaultingMapBasedFactory") />
	<cfset var args = structNew() />
	<cfset var inst = "" />
	
	<cfset args.arg = "argValue" />
	
	<cfset fac.init(constructorArgs=args) />
	
	<cfset inst = fac.create("unittests.factory.ImplOne") />

	<cfset assertTrue(inst.arg eq "argValue", "constructor arg not set!") />	
</cffunction>

</cfcomponent>