<cfset navSections = event.getValue("navigationSections", arrayNew(1)) />
<cfimport prefix="common" taglib="/modelglueactionpacks/common/tags" /> 

<html>
<head>
	<link rel="stylesheet" type="text/css" href="/modelglueactionpacks/common/assets/css/stylesheet.css"></link>
</head>

<body>
<div id="maincontainer">

<div id="topsection">
	<div class="innertube">
		<h1>Model-Glue 3 Actionpacks Common Template</h1>
		<!--- Display the view named "user" --->
		<cfoutput>#viewCollection.getView("user")#</cfoutput>
	</div>
</div>

<div id="contentwrapper">
	<div id="contentcolumn">

		<div class="innertube">
			<!--- Display the view named "body" --->
			<cfoutput>#viewCollection.getView("body")#</cfoutput>
		</div>
	</div>
</div>
	
<div id="leftcolumn">
	<div class="innertube">
		
		<cfloop from="1" to="#arrayLen(navSections)#" index="i">
			<common:navigationSection section="#navSections[i]#" event="#event#" />
		</cfloop>
	</div>
</div>

<cfoutput>
<div id="footer">
	<p>
		Model-Glue is &copy; #dateFormat(now(), "yyyy")# <a href="http://www.firemoss.com">Joe Rinehart</a>.  It's open source and free, released under the <a href="http://www.apache.org/licenses/LICENSE-2.0.html">Apache License, Version 2.0</a>.
	</p>
	<p>
		Thanks to 
		<a href="http://www.corfield.org">Sean Corfield</a>, 
		<a href="http://www.coldfusionjedi.com/">Raymond Camden</a>,
		<a href="http://www.briankotek.com/blog/">Brian Kotek</a>,
		<a href="http://www.compoundtheory.com">Mark Mandel</a>,
		<a href="http://en.wikipedia.org/wiki/Ayn_Rand">Ayn Rand</a>,
		<a href="http://www.d-ross.org">Dave Ross</a>,
		<a href="http://cdscott.blogspot.com/">Chris Scott</a>,
		<a href="http://www.firemoss.com">Firemoss</a>,
		<a href="http://www.alagad.com">Alagad</a>,
		<a href="http://www.aboutweb.com">AboutWeb</a>,
		and most of all
		Dale and Ava Rinehart.
	</p>
</div>
</cfoutput>
	
</div>

</body>

</html>