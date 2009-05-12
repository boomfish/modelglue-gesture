<cfcomponent output="false">
	
	<cfset variables._scaffoldBeanRegistry = structNew() />
	<cffunction name="init" access="public" returntype="ScaffoldManager">
		<cfargument name="ModelGlueConfiguration" type="struct" required="true"/>
		<cfargument name="scaffoldBeanRegistry" type="any" required="true"/>
		<cfset  variables._MGConfig.scaffoldCFPath = arguments.ModelGlueConfiguration.getFullGeneratedViewMapping() />
		<cfset  variables._MGConfig.expandedScaffoldFilePath= replace( expandPath( variables._MGConfig.scaffoldCFPath ), "\", "/", "all" )   />
		<cfset  variables._MGConfig.scaffoldXMLFilePath= replace( expandPath( arguments.ModelGlueConfiguration.getScaffoldPath() ) , "\",  "/", "all")   />
		<cfset  variables._MGConfig.shouldRescaffold= arguments.ModelGlueConfiguration.getRescaffold() />
		<cfset structAppend( variables._scaffoldBeanRegistry, arguments.scaffoldBeanRegistry ) />
		
		<!--- Only bother hitting the disk if we are rescaffolding--->
		<cfif variables._MGConfig.shouldRescaffold IS true>
			<cfset makeSureConfigFileExists() />
			<cfset makeSureViewMappingFolderExists() />
		</cfif>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="addScaffoldTemplate" output="false" access="public" returntype="array" hint="I add a scaffolding bean configuration to the known scaffolding beans">
		<cfargument name="configArray" type="array" required="true"/>
		<cfset var i = "" />
		<cfloop from="1" to="#arrayLen( arguments.configArray)#" index="i">
			<cfset variables._scaffoldBeanRegistry[ arguments.configArray[i].type ] = arguments.configArray[i].data />
		</cfloop>
		<cfreturn arguments.configArray />
	</cffunction>
	
	<cffunction name="generate" output="false" access="public" returntype="void" hint="I generate the scaffolds and load them into the model glue memory space">
		<cfargument name="scaffolds" />	
		<cfset var scaffoldsXMLContent = "" />
		<cfset var inflatedScaffoldArray = arrayNew( 1 ) />
		<cfset var i = "" />
		<cfset var _ormAdapter = findOrmAdapter()  />
		<!--- OK, so inflate the scaffolds using the beans configured (or overridden) in the ColdSpring bean factories --->
		<cfloop from="1" to="#arrayLen( arguments.scaffolds )#" index="i">
			<cfset arrayAppend( inflatedScaffoldArray, new( arguments.scaffolds[i].type, _ormAdapter.getObjectMetadata( arguments.scaffolds[i].object ), arguments.scaffolds[i].propertylist )) />
		</cfloop>
		
		<!--- Yes this line is rediculously long, but we want to control whitespace, don't we?' --->
		<!--- Gen the XML --->
 		<cfsavecontent variable="scaffoldsXMLContent"><cfloop from="1" to="#arrayLen( inflatedScaffoldArray )#" index="i"><cfif inflatedScaffoldArray[i].hasXMLGeneration IS true ><cfoutput>#inflatedScaffoldArray[i].makeMGXMLWithMetadata()#</cfoutput></cfif></cfloop></cfsavecontent>
		<cfset writeToDisk( variables._MGConfig.scaffoldXMLFilePath, scaffoldsXMLContent ) /> 
		
		<!--- Gen the Views --->
		<cfloop from="1" to="#arrayLen( inflatedScaffoldArray )#" index="i">
			<cfif inflatedScaffoldArray[i].hasViewGeneration IS true >
				<cfset cftemplate(	inflatedScaffoldArray[i].loadMetadata(), 
												inflatedScaffoldArray[i].loadViewTemplateWithMetadata(),
												inflatedScaffoldArray[i].makeFullFilePathAndNameForView( variables._MGConfig.expandedScaffoldFilePath ) ) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="writeToDisk" output="false" access="private" returntype="void" hint="I save the generated scaffolds.xml file to disk">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="scaffoldXMLString" type="string" required="true" />
		<cffile action="write" file="#arguments.location#" output="#makeTopOuterNode() & arguments.scaffoldXMLString & makeBottomOuterNode()#" />
	</cffunction>
	
	<cffunction name="makeSureConfigFileExists" output="false" access="private" returntype="void" hint="I make sure the scaffold config file exists">
		<cfset var content = makeTopOuterNode() &  makeBottomOuterNode() />
		<cfif fileExists( variables._MGConfig.scaffoldXMLFilePath ) IS false>
			<cffile action="write" file="#variables._MGConfig.scaffoldXMLFilePath#" output="#content#" />
		</cfif> 
	</cffunction>
	
	<cffunction name="makeSureViewMappingFolderExists" output="false" access="private" returntype="void" hint="I make sure the scaffold config file exists">
		<cfif directoryExists( variables._MGConfig.expandedScaffoldFilePath ) IS false>
			<cfdirectory action="create" directory="#variables._MGConfig.expandedScaffoldFilePath#">
		</cfif>
	</cffunction>

	<cffunction name="makeTopOuterNode" output="false" access="private" returntype="string" hint="I return the top portion of the file">
		<cfreturn ('<?xml version="1.0" encoding="UTF-8"?>
<!-- Warning! This file is generated and will be overwritten whenever ModelGlue feels like it. Do Not Make Your Customizations Here!-->
<modelglue>

	<event-handlers>
') />
	</cffunction>

	<cffunction name="makeBottomOuterNode" output="false" access="private" returntype="string" hint="I return the top portion of the file">
		<cfreturn ('
	</event-handlers>

</modelglue>') />
	</cffunction>

	<cffunction name="findORMAdapter" output="false" access="private" returntype="any" hint="I find the ORM Adapter if one was loaded. If not, I cry like a baby">
		<cftry>
			<cfreturn variables._modelGlue.getInternalBean("OrmAdapter") />
			<cfcatch type="coldspring.NoSuchBeanDefinitionException">
				<cfthrow type="ModelGlue.Scaffolding" message="Scaffolding Requires Functional Configured ORM Adapter" detail="You tried to scaffold something and we can't find an ORMAdapter. Either configure one, or figure out what is wrong with the one you configured. Sorry, we can't help you." />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="new" output="false" access="private" returntype="any" hint="I make a new instance of a scaffoldbean">
		<cfargument name="name" type="string" required="true"/>
		<cfargument name="constructorArgs" type="struct" default="#structNew()#"/>
		<cfargument name="propertylist" type="string" default=""/>
		<cfset var beanConstructor = structNew() />
		<!--- mix in the arguments --->
		<cfset structAppend( beanConstructor, arguments ) />
		<!--- now specifically get the constructor args out and mix those in --->
		<cfset structAppend( beanConstructor, arguments.constructorArgs ) />
		<!--- mix in the stuff from the original config. --->
		<cfset structAppend( beanConstructor, variables._scaffoldBeanRegistry[ arguments.name ] ) />
		<cfset beanConstructor.advice = findAdvice( arguments.name ) ><!--- todo: This doesn't work yet.'--->
		<!--- make the object and return it --->
		<cfreturn createobject("component", variables._scaffoldBeanRegistry[ arguments.name ].class ).init( argumentcollection:beanConstructor ) />
	</cffunction>

	<cffunction name="getModelGlue" access="public" output="false" returntype="any">
		<cfreturn variables._modelGlue />
	</cffunction>
	
	<cffunction name="setModelGlue" access="public" output="false" returntype="void">
		<cfargument name="ModelGlue" type="ModelGlue.gesture.ModelGlue" required="true" />
		<cfset variables._modelGlue = arguments.ModelGlue />
	</cffunction>
	
	<cffunction name="findAdvice" access="private" output="false" returntype="struct" hint="I am advice for the specific object. You can alter the behaviour of the scaffolding by configuring advice per object in coldspring.">
		<cfargument name="name" type="string" default="" />
		<cfreturn structNew() />
	</cffunction>
	
	<cffunction name="cftemplate" returntype="string" access="public" output="no" hint="I generate a script using a cf-template and its associated metadata. This is modified from cftemplate.riaforge.org">
		<cfargument name="Metadata" type="any" required="yes" hint="The metadata required for generation." />
		<cfargument name="TemplateScript" type="string" required="yes" hint="I am the content conforming to the CF Template syntax.">
		<cfargument name="DestinationFilePath" type="string" required="yes" hint="The physical path to publish the generated script to including the file name and file extension.">
		<cfset var TemplateScratchpadName = "#CreateUUID()#.cfm">
		<cfset var GeneratedScript = "" />
		<cfset var OpenTagString = "<<"/>
		<cfset var CloseTagString = ">>"/>
		<cfset var VariableString = "%"/>
		<cfset var EscapedVariableString = "%%"/>

		<cfscript>
			// TRANSFORM TEMPLATE FOR PROCESSING
			// Turn CF Template tag and variable identifiers into arbritrary strings
			TemplateScript = Replace(TemplateScript, OpenTagString, "!!START_CFTEMPLATE!!", "all");
			TemplateScript = Replace(TemplateScript, CloseTagString, "!!END_CFTEMPLATE!!", "all");
			TemplateScript = Replace(TemplateScript, EscapedVariableString, "!!EscapedVariableString!!", "all");
			TemplateScript = Replace(TemplateScript, VariableString, "!!VariableString!!", "all");
	
			// Turn ColdFusion tag and variable identifiers into arbritrary strings
			TemplateScript = Replace(TemplateScript, "<", "!!START_CF_TAG!!", "all");
			TemplateScript = Replace(TemplateScript, ">", "!!END_CF_TAG!!", "all");
			TemplateScript = Replace(TemplateScript, "####", "!!EscapedCFVariableString!!", "all");
			TemplateScript = Replace(TemplateScript, "##", "!!CFVariableString!!", "all");
			
			// Turn CF Template tag and variable identifiers into ColdFusion tag and variable identifiers
			TemplateScript = Replace(TemplateScript, "!!START_CFTEMPLATE!!", "<", "all");
			TemplateScript = Replace(TemplateScript, "!!END_CFTEMPLATE!!", ">", "all");
			TemplateScript = Replace(TemplateScript, "!!VariableString!!", "##", "all");
			
		</cfscript>	
		
		<!--- Save the transformed template to the scratchpad directory for parsing --->
		<cffile action="write" addnewline="yes" file="#variables._MGConfig.expandedScaffoldFilePath#/#TemplateScratchpadName#" output="#TemplateScript#" fixnewline="no">
		<!--- Run the template to generate code --->
		<cfsavecontent variable="GeneratedScript"><cfinclude template="#variables._MGConfig.scaffoldCFPath#/#TemplateScratchpadName#"></cfsavecontent>
		<!--- Delete any scratchpad files --->
		<cfif fileExists( "#variables._MGConfig.expandedScaffoldFilePath#/#TemplateScratchpadName#" )>
			<cffile action="delete" file="#variables._MGConfig.expandedScaffoldFilePath#/#TemplateScratchpadName#">
		</cfif>

		<cfscript>
			// Transform the code back to CF
			GeneratedScript = Replace(GeneratedScript, "!!START_CF_TAG!!", "<", "all");
			GeneratedScript = Replace(GeneratedScript, "!!END_CF_TAG!!", ">", "all");
			GeneratedScript = Replace(GeneratedScript, "!!EscapedCFVariableString!!", "####", "all");
			GeneratedScript = Replace(GeneratedScript, "!!CFVariableString!!", "##", "all");
			GeneratedScript = Replace(GeneratedScript, "!!EscapedVariableString!!", EscapedVariableString, "all");
		</cfscript>	

		<cffile action="write" addnewline="no" file="#DestinationFilePath#" output="#GeneratedScript#" fixnewline="no">
	</cffunction>

	<cffunction name="spaceCap" output="false" access="private" returntype="string" hint="I return a string with a space before each capital letter: author Mark W. Breneman (Mark@vividmedia.com) ">
		<cfargument name="x" type="string" required="true"/>
		<cfreturn REReplace(x, "([.^[:upper:]])", " \1","all") />
	</cffunction>
	
	<cffunction name="makeQuerySourcedPrimaryKeyURLString" output="false" access="public" returntype="string" hint="I make a url string for the primary keys of this object">
		<cfargument name="_alias" type="string" required="true"/>
		<cfargument name="_primaryKeyList" type="string" required="true"/>
		<cfset var urlString = "" />	
		<cfset var pk = "" />
		<cfloop list="#arguments._primaryKeyList#" index="pk">
			<cfset urlString = listAppend( urlString, "&#pk#=###arguments._alias#Query.#pk###") />
		</cfloop>
		<cfreturn urlString />
	</cffunction>
	
	<cffunction name="makeBeanSourcedPrimaryKeyURLString" output="false" access="public" returntype="string" hint="I make a url string for the primary keys of this object">
		<cfargument name="_alias" type="string" required="true"/>
		<cfargument name="_primaryKeyList" type="string" required="true"/>
		<cfset var urlString = "" />	
		<cfset var pk = "" />
		<cfloop list="#arguments._primaryKeyList#" index="pk">
			<cfset urlString = listAppend( urlString, "&#pk#=###arguments._alias#Record.get#pk#()##") />
		</cfloop>
		<cfreturn urlString />
	</cffunction>
	
	<cffunction name="makePrimaryKeyHiddenFields" output="false" access="public" returntype="string" hint="I make hidden fields for the primary keys of this object">
		<cfargument name="_alias" type="string" required="true"/>
		<cfargument name="_primaryKeyList" type="string" required="true"/>
		<cfset var hiddenFieldString = "" />	
		<cfset var pk = "" />
		<cfloop list="#arguments._primaryKeyList#" index="pk">
			<cfset hiddenFieldString = listAppend( hiddenFieldString, '
	<input type="hidden" name="#pk#" value="###arguments._alias#Record.get#pk#()##">', " ") />
		</cfloop>
		<cfreturn hiddenFieldString />
	</cffunction>
	
	<cffunction name="makePrimaryKeyCheckForIsNew" output="false" access="public" returntype="string" hint="I make an evaluation to find out whether or not this is an existing record">
		<cfargument name="_alias" type="string" required="true"/>
		<cfargument name="_primaryKeyList" type="string" required="true"/>
		<cfset var PrimaryKeyCheck = "" />	
		<cfset var pk = "" />
		<cfloop list="#arguments._primaryKeyList#" index="pk">
			<cfset PrimaryKeyCheck = listAppend( PrimaryKeyCheck, "#arguments._alias#Record.get#pk#()", "&") />
		</cfloop>
		<cfreturn "len( trim(" & PrimaryKeyCheck & ") )"/>
	</cffunction>
	
</cfcomponent>