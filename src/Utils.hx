package ;

class Utils
{
  private static var compilation_vars : Map<String, Dynamic>;

  public static function setEnvironmentVar(pName: String, pValue: Dynamic)
  {
    if(compilation_vars == null) compilation_vars = new Map<String, Dynamic>();
    compilation_vars.set(pName, getPath(pValue));
  }

  public static function getPath(pVal: String): String
  {
    var r = ~/\${([a-z1-9_]+)}/g;
    var s2 = r.map(pVal, function(r) {
      var match = r.matched(0);
      match = StringTools.replace(match, "${", "");
      match = StringTools.replace(match, "}", "");

      if(compilation_vars == null || !compilation_vars.exists(match))
      {
        Sys.println("No variable defines for " + match);
        Sys.exit(1);
      }

      return compilation_vars.get(match);
    });
    return s2;
  }
}
