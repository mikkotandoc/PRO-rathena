using System;
using System.IO;
using NLua;

var lua = new Lua();
try {
	var bytes = File.ReadAllBytes(args[0]);
	var chunk = System.Text.Encoding.GetEncoding(28591).GetString(bytes);
	lua.DoString(chunk, "itemInfo_C");
	var tbl = lua.GetTable("tbl_override");
	int n = 0;
	foreach (var k in tbl.Keys) n++;
	Console.WriteLine($"OK: tbl_override entries = {n}");
	foreach (var id in new[] { 450439L, 460117L, 401043L, 410496L, 490787L, 490791L, 450386L, 480338L, 490526L, 1000700L, 1000701L }) {
		var e = tbl[id] as LuaTable;
		Console.WriteLine(id + " => " + (e == null ? "MISSING" : (e["identifiedDisplayName"] ?? "?")));
	}
} catch (Exception ex) {
	Console.WriteLine("LUA ERROR: " + ex.Message);
	Environment.Exit(1);
}
