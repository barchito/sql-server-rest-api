// Example:
// ID op DIGIT op ID op (DIGIT op ID) op ID op STRING_LITERAL op (DIGIT op DIGIT )s
lexer grammar FilterTranslator;

@lexer::members {
    SqlServerRestApi.TableSpec tableSpec;
	SqlServerRestApi.QuerySpec querySpec;
	int i = 0;
	public FilterTranslator(ICharStream input,
							SqlServerRestApi.TableSpec tableSpec,
							SqlServerRestApi.QuerySpec querySpec): base(input) 
	{
		this.tableSpec = tableSpec;
		this.querySpec = querySpec;
		this.querySpec.parameters = new System.Collections.Generic.LinkedList<System.Data.SqlClient.SqlParameter>();
		_interp = new LexerATNSimulator(this,_ATN);
	}
}

//Translated tokens
OPERATOR : 'eq' { Text = "="; } | 'ne' { Text = "<>"; } |
			'gt' { Text = ">"; } | 'ge' { Text = ">="; } |
			'lt' { Text = "<"; } | 'le' { Text = "<="; } |
			'add' { Text = "+"; } | 'sub' { Text = "-"; } |
			'mul' { Text = "*"; } | 'div' { Text = "/"; } |
			'mod' { Text = "%"; } |
			// Operators that are not translated but they need to skip identifier check.
			'and' { Text = " AND "; } | 'or' { Text = " OR "; } |
			'not' { Text = " NOT "; };
FUNCTION :	'contains(' { Text = "odata.contains("; } |
			'endswith(' { Text = "odata.endswith("; } |
			'indexof(' { Text = "odata.indexof("; } |
			'length(' { Text = "len("; } |
			'startswith(' { Text = "odata.startswith("; } |
			'tolower(' { Text = "lower("; } |
			'touper(' { Text = "lower("; } |
			'trim(' { Text = "TRIM( CHAR(20) FROM "; } |
			'year(' { Text = "datepart(year,"; } |			
			'month(' { Text = "datepart(month,"; } |
			'day(' { Text = "datepart(day,"; } |
			'hour(' { Text = "datepart(hour,"; } |
			'minute(' { Text = "datepart(minute,"; } |
			'second(' { Text = "datepart(second,"; }
// Non standard functions
			| 'json_value(' { Text = "json_value("; }
			| 'json_query(' { Text = "json_query("; }
			| 'json_modify(' { Text = "json_modify("; }
			| 'isjson(' { Text = "isjson("; }
			| 'json_cast(' { Text = "json_query("; }
			;

UNSUPPORTEDFUNCTION: '[_a-zA-Z][_a-zA-Z0-9"."]*(' {throw new System.ArgumentException("Unsupported function: " + Text);};
DATETIME_LITERAL: 'datetime'STRING_LITERAL { 

		var p = new System.Data.SqlClient.SqlParameter("@p"+i, System.Data.SqlDbType.DateTimeOffset);
		p.Value = System.DateTime.Parse(Text.Substring(9,Text.Length-10));
		this.querySpec.parameters.AddFirst(p);
		Text = "@p"+(i++);

};

WS : [ \n\u000D\r\t]+ -> skip;
STRING_LITERAL : ['].*?['] { 
		var p = new System.Data.SqlClient.SqlParameter("@p"+i, System.Data.SqlDbType.NVarChar, 4000);
		p.Value = Text.Substring(1,Text.Length-2);
		this.querySpec.parameters.AddFirst(p);
		Text = "@p"+(i++);
};
NUMBER : [1-9][0-9]* {
		var p = new System.Data.SqlClient.SqlParameter("@p"+i, System.Data.SqlDbType.Int);
		p.Value = System.Convert.ToInt32(Text);
		this.querySpec.parameters.AddFirst(p);
		Text = "@p"+(i++); 
};
PROPERTY : [_@#a-zA-Z][a-zA-Z0-9_@#]* { this.tableSpec.HasColumn(Text);};
TEXT : [".""("")"]+;