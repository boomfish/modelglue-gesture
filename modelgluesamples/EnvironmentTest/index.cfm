<cfparam name="url.mode" default="run" /> 

<cfif url.mode IS "run">

	<cfset data = getEnvironmentData() />


	<style>
	* {
		font-family: verdana;
	}
	table {
		border-collapse:collapse;
		width: 500px;	
	}
	table td {
		padding: 4px;
		border: 1px solid #ccc;
	}
	</style>

<cfoutput>

	<h3>System Information</h3>
	<p>To post these details privately to <a href="http://modelglue.pastebin.com">pastebin.com</a> click <a href="?mode=paste">here</a></p>
	<table>
		<tr>
			<td>Operating System</td>
			<td>#data.jvmprops.os_name#</td>
		</tr>
		<tr>
			<td>System Architecture</td>
			<td>#data.jvmprops.os_arch#</td>
		</tr>
		<tr>
			<td>JVM Version</td>
			<td>#data.jvmprops.java_version#</td>
		</tr>
	</table>

	<h3>CFML Engine</h3>
	<table>
		<tr>
			<td>Application Server</td>
			<td>#data.engine.appserver#</td>
		</tr>
		<tr>
			<td>Name</td>
			<td>#data.engine.name#</td>
		</tr>
		<tr>
			<td>Version</td>
			<td>#data.engine.version#</td>
		</tr>
	</table>

	<h3>Web Server</h3>
	<table>
		<tr>
			<td>Name</td>
			<td>#data.webserver.server#</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>Supports SES Urls?</td>
			<td>#getText(data.webserver.sesurls)#</td>
			<td><img src="#getIcon(data.webserver.sesurls)#" /></td>
		</tr>
	</table>

	<h3>Debugging & Monitoring</h3>
	<table>
		<tr>
			<td>Is Debugging switched on?</td>
			<td>#getText(data.debug.debugging)#</td>
			<td><img src="#getIcon(data.debug.debugging, true)#" /></td>
		</tr>
		<tr>
			<td>Is Report Execution Times switched on?</td>
			<td>#getText(data.debug.reportexecutiontime)#</td>
			<td><img src="#getIcon(data.debug.reportexecutiontime, true)#" /></td>
		</tr>
		<tr>
			<td>Is Monitoring Turned on?</td>
			<td>#getText(data.monitoring.monitoring)#</td>
			<td><img src="#getIcon(data.monitoring.monitoring, true)#" /></td>
		</tr>
		<tr>
			<td>Is Memory Monitoring Turned on?</td>
			<td>#getText(data.monitoring.memory)#</td>
			<td><img src="#getIcon(data.monitoring.memory, true)#" /></td>
		</tr>
		<tr>
			<td>Is Profiling Turned on?</td>
			<td>#getText(data.monitoring.profiling)#</td>
			<td><img src="#getIcon(data.monitoring.profiling, true)#" /></td>
		</tr>
	</table>

	<h3>Memory</h3>
	<table>
		<tr>
			<td>Total Memory</td>
			<td>#byteConvert(data.memory.total)#</td>
		</tr>
		<tr>
			<td>Maximum Memory</td>
			<td>#byteConvert(data.memory.max)#</td>
		</tr>
		<tr>
			<td>Free Memory</td>
			<td>#byteConvert(data.memory.free)#</td>
		</tr>
	</table>
</cfoutput>

<cfelseif url.mode IS "paste">
	<cfset data = structToText(getEnvironmentData()) />
	<cfhttp url="http://modelglue.pastebin.com/api_public.php" method="post">
		<cfhttpparam type="formfield" name="paste_code" value="#data#" /> 
		<cfhttpparam type="formfield" name="paste_expire_date" value="N" /> 
		<cfhttpparam type="formfield" name="paste_format" value="text" /> 
		<cfhttpparam type="formfield" name="paste_private" value="1" /> 
		<cfhttpparam type="formfield" name="paste_subdomain" value="modelglue" /> 
	</cfhttp>
	<cfset pburl = trim(cfhttp.filecontent) />
	<cfoutput>
	<p>
		Your environment info has been posted (privately) to pastebin at url below<br>
		Please copy this url into any messages to the <a href="https://groups.google.com/group/model-glue">ModelGlue group</a>
	</p>
	<p><a href="#pburl#">#pburl#</a></p>
	
	<pre>#data#</pre>
	
	
	
	</cfoutput>

<cfelseif url.mode IS "ses">
	<cfsetting showdebugoutput="false" />
	<cfparam name="url.value" default="" />
	<cfparam name="cgi.path_info" default="" />
	<cfcontent reset="true" /><cfoutput>#cgi.path_info#,#url.value#</cfoutput><cfabort>
</cfif>


<cffunction name="structToText" output="false">
	<cfargument name="struct" />
	<cfargument name="indent" default="0" />
	<cfset var i="" />
	<cfset var s = "" />
	<cfloop collection="#struct#" item="i">
		<cfif isSimpleValue(struct[i])>
			<cfset s = s & repeatstring(chr(9), arguments.indent) & "#i#: #struct[i]# #chr(10)#" />
		<cfelseif isStruct(struct[i])>
			<cfset s = s & "#i#: #chr(10)#" />
			<cfset s = s & structToText(struct[i], arguments.indent+1) />		
		</cfif>
	</cfloop>
	<cfreturn s />
</cffunction>



<cffunction name="getText" output="false">
	<cfargument name="value" />
	<cfif isBoolean(arguments.value)>
		<cfreturn yesnoformat(arguments.value) />
	</cfif>
	<cfreturn arguments.value />
</cffunction>

<cffunction name="getIcon" output="false">
	<cfargument name="value" type="string" />
	<cfargument name="invert" type="boolean" default="false" />
	
	<cfif isBoolean(arguments.value)>
		<cfif arguments.invert>
			<cfset arguments.value = NOT arguments.value />
		</cfif>
	
		<cfif arguments.value>
			<cfreturn "check.png" />
		<cfelse>
			<cfreturn "cross.png" />
		</cfif>
	<cfelse>
		<cfreturn "question.png" />
	</cfif>
	
</cffunction>


<cffunction name="getEnvironmentData" output="false">
	<cfset var data = structnew() />
	<cfset data.debug = getDebugStatus() />
	<cfset data.monitoring = getMonitoring() />
	<cfset data.jvmprops = getJvmProps() />
	<cfset data.webserver = getWebServer() />
	<cfset data.engine = getEngine() />
	<cfset data.memory = getJvmMemory() />
	<cfreturn data />
</cffunction>  


<cffunction name="getEngine" output="false">
	<cfset var ret = structnew() />
	<cfset ret.name = server.coldfusion.productname />
	<cfset ret.version = server.coldfusion.productversion />
	<cfset ret.appserver = server.coldfusion.appserver />
	<cfreturn ret />
</cffunction>

<cffunction name="getWebServer" output="false">
	<cfset var path = "" />
	<cfset var value = "" />
	<cfset var ret = structnew() /> 
	<cfset ret.sesurls = false />
	<cfset ret.server = "" />
	<cfhttp url="#cgi.http_host#/#cgi.script_name#/some/path?mode=ses&value=foo" />
	
	<cfparam name="cfhttp.responseheader.status_code" default="" />
	<cfparam name="cfhttp.responseheader.server" default="UNKNOWN" />
	
	<cfset ret.server = cfhttp.responseheader.server />
	
	<cfif listlen(cfhttp.filecontent) IS 2>
		<cfset path = listfirst(cfhttp.filecontent) />
		<cfset value = listlast(cfhttp.filecontent) />
		<cfif cfhttp.responseheader.status_code IS 200 AND path IS "/some/path" AND value IS "foo">
			<cfset ret.sesurls = true />
		</cfif>
	</cfif> 
	<cfreturn ret />
</cffunction>

<cffunction name="getJvmMemory" output="false">
	<cfset var rt = 0 />
	<cfset var mem = structnew() />
	<cfset mem.max = 0 />
	<cfset mem.used = 0 />
	<cfset mem.total = 0 />
	<cfset mem.free = 0 />

	<cftry>
		<cfset rt = createObject("java","java.lang.Runtime").getRuntime()>
		<cfset mem.max = rt.maxMemory() />	
		<cfset mem.free = rt.freeMemory() />
		<cfset mem.total = rt.totalMemory() />
		<cfset mem.used = mem.total-mem.free />
		<cfcatch type="Any">
		</cfcatch>
	</cftry>
	<cfreturn mem />
</cffunction>

<cffunction name="getJvmProps" output="false">
	<cfset var props = structnew() />
	<cfset var sys = 0 />
	<cfset var i = "" />
	<cfset key = "" />
	<cfloop list="java.version,os.name,os.arch" index="i">
		<cftry>
			<cfobject action="CREATE" type="JAVA" class="java.lang.System" name="sys">
			<cfset key = replace(i, ".", "_", "ALL") />
			<cfset props[key] = sys.getProperty(i) />
			<cfcatch type="Any">
				<cfset props[key] = "" />
			</cfcatch>
		</cftry>
	</cfloop>
	<cfreturn props />
</cffunction>

<cffunction name="getMonitoring" output="false">
	<cfset ret = structnew() />
	<cfset ret.memory = "UNKNOWN" />
	<cfset ret.profiling = "UNKNOWN" />
	<cfset ret.monitoring = "UNKNOWN" />
	<cfset var factory = 0 />
	 
	<cftry>
		<cfobject action="CREATE" type="JAVA" class="coldfusion.server.ServiceFactory" name="factory">
		<cfset ret.memory = factory.getMonitoringService().isMemoryMonitoringEnabled() />
		<cfset ret.profiling = factory.getMonitoringService().isProfilingEnabled() />
		<cfset ret.monitoring = factory.getMonitoringService().isMonitoringEnabled() />
		
		<cfcatch type="Any"></cfcatch>
	</cftry>
	<cfreturn ret />
</cffunction>

<cffunction name="getDebugStatus" output="false">
	<cfset var tempfile = "#createuuid()#.cfm" /> 
	<cfset var factory = 0 />
	<cfset var ret = structnew() />
	<cfset ret.debugging = isDebugMode() />
	<cfset ret.reportexecutiontime = "UNKNOWN" />
	
	<cftry>
		<!--- this page wont get added to the execution time data until its finished processing
		 so we need to include a file to make sure that theres one in the debugging data --->
		<cffile action="write" file="#expandpath('./#tempfile#')#" output=""  />
		<cfinclude template="#tempfile#" />
		<cffile action="delete" file="#expandpath('./#tempfile#')#" />
		<!--- this will throw if debugging is not on, so we can't check report execution times --->
		<cfobject action="CREATE" type="JAVA" class="coldfusion.server.ServiceFactory" name="factory">
		<cfset debugTable = factory.getDebuggingService().getDebugger().getData()>
		<cfquery dbType="query" name="getTemplates" debug="false">
			SELECT template
			FROM debugTable
			WHERE type = 'Template'
		</cfquery>
		<cfif getTemplates.recordcount>
			<cfset ret.reportexecutiontime = "YES" />
		<cfelse>
			<cfset ret.reportexecutiontime = "NO" />
		</cfif>
		<cfcatch type="Any"></cfcatch>
	</cftry>
	<cfreturn ret />
</cffunction>
	

<cfscript>
/**
* Pass in a value in bytes, and this function converts it to a human-readable format of bytes, KB, MB, or GB.
* Updated from Nat Papovich's version.
* 01/2002 - Optional Units added by Sierra Bufe (sierra@brighterfusion.com)
* 
* @param size      Size to convert. 
* @param unit      Unit to return results in. Valid options are bytes,KB,MB,GB. 
* @return Returns a string. 
* @author Paul Mone (sierra@brighterfusion.compaul@ninthlink.com) 
* @version 2.1, January 7, 2002 
*/
function byteConvert(num) {
    var result = 0;
    var unit = "";
    
    // Set unit variables for convenience
    var bytes = 1;
    var kb = 1024;
    var mb = 1048576;
    var gb = 1073741824;

    // Check for non-numeric or negative num argument
    if (not isNumeric(num) OR num LT 0)
        return "Invalid size argument";
    
    // Check to see if unit was passed in, and if it is valid
    if ((ArrayLen(Arguments) GT 1)
        AND ("bytes,KB,MB,GB" contains Arguments[2]))
    {
        unit = Arguments[2];
    // If not, set unit depending on the size of num
    } else {
         if (num lt kb) {    unit ="bytes";
        } else if (num lt mb) {    unit ="KB";
        } else if (num lt gb) {    unit ="MB";
        } else {    unit ="GB";
        }        
    }
    
    // Find the result by dividing num by the number represented by the unit
    result = num / Evaluate(unit);
    
    // Format the result
    if (result lt 10)
    {
        result = NumberFormat(Round(result * 100) / 100,"0.00");
    } else if (result lt 100) {
        result = NumberFormat(Round(result * 10) / 10,"90.0");
    } else {
        result = Round(result);
    }
    // Concatenate result and unit together for the return value
    return (result & " " & unit);
}
</cfscript>
	