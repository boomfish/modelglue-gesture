component persistent="true" output="false"
{
	property name="many2many_structId" fieldtype="id" generator="native";
	property name="type_binary" type="binary";
	property name="type_boolean" type="boolean";
	property name="type_date" type="date";
	//property name="type_guid" type="guid";
	property name="type_numeric" type="numeric";
	property name="type_string" type="string";
	//property name="type_uuid" type="uuid";

	//property name="mainObjects_struct" fieldtype="many-to-many" cfc="MainObject" linktable="main_many2many_struct" type="struct" structkeycolumn="mainId" fkcolumn="many2many_structId";
}
