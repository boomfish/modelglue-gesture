<!---

This is a basic "wrapper" template for your application.

It expects you to run an event that includes a view named "body".
---><html>

<head>
	<link rel="stylesheet" type="text/css" href="css/stylesheet.css"></link>
</head>

<body>
	<div id="banner">Model-Glue 3 ("Gesture")</div>
	
	<!--- Display the view named "body" --->
	<cfoutput>#viewCollection.getView("body")#</cfoutput>
	
	<cfoutput>
	<div id="footer">
		<p>
			Model-Glue is &copy; #dateFormat(now(), "yyyy")# <a href="http://www.firemoss.com">Joe Rinehart</a>.  It's open source and free, released under the <a href="http://www.apache.org/licenses/LICENSE-2.0.html">Apache License, Version 2.0</a>.
		</p>
		<p>
			Thanks to 
			<a href="http://www.coldfusionjedi.com/">Raymond Camden</a>,
			<a href="http://www.corfield.org">Sean Corfield</a>, 
			<a href="http://www.web-relevant.com/blogs/cfobjective">Jared Rypka-Hauer</a>,
			<a href="http://www.briankotek.com/blog/">Brian Kotek</a>,
			<a href="http://www.compoundtheory.com">Mark Mandel</a>,
			<a href="http://en.wikipedia.org/wiki/Ayn_Rand">Ayn Rand</a>,
			<a href="http://www.d-ross.org">Dave Ross</a>,
			<a href="http://cdscott.blogspot.com/">Chris Scott</a>,
			<a href="http://www.boyzoid.com">Scott Stroz</a>,
			<a href="http://www.nodans.com">Dan Wilson</a>,
			<a href="http://www.firemoss.com">Firemoss</a>,
			<a href="http://www.alagad.com">Alagad</a>,
			<a href="http://www.aboutweb.com">AboutWeb</a>,
			<a href="http://www.datacurl.com">DataCurl</a>,			
			and most of all
			Dale and Ava Rinehart.
		</p>
	</div>
	<table>
		<tr>
			<td><strong>Documentation Team</strong></td>
			<td><a href="http://cfgrok.com">Ezra Parker</a></td>
		</tr>
		<tr>
			<td><strong>Integration/Deployment Team</strong></td>
			<td><a href="http://thecrumb.com">Jim Priest</a></td>
		</tr>
	</table>
	</cfoutput>
</body>

</html>