package ;

import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;

import haxe.Json;

import plugins.ITask;
import plugins.Copy;
import plugins.Execute;
import plugins.HaxeCommand;
import plugins.TemploBuilder;

/**
    Helper to build and deploy local haxe applications
 **/
class Sequence extends mcli.CommandLine
{
  /**
    Données provenant du JSON
   **/
  @:skip private var _project : PProject;

  /**
    Root directory
   **/
  @:skip private var _root : String;

  /**
    Use value for given property
		@key    property
		@value  value
	**/
	public var D:Map<String,String> = new Map();

  /**
    Display this help
   **/
  public function help()
  {
    Sys.println(this.showUsage());
    Sys.exit(0);
  }

  /**
     Run Flow command with a json configuration file
   **/
  public function runDefault(config_file: String, ?root_path : String)
  {
    // root_path != null if launched via haxelib
    _root = root_path != null ? root_path : "";
    config_file = Path.join( [_root, config_file] );

    if(!FileSystem.exists(config_file))
    {
      Sys.println(config_file + " not found");
      exitTool();
    }

    var file = File.getContent( config_file );

    try{
      _project = Json.parse(file);
    }catch ( error:Dynamic ){
      Sys.println("Can't parse the json file");
      exitTool();
    }

    Sys.println("\n-- hxSEQUENCE TOOL --\n");

    var manifest = _project.manifest;

    Sys.println(manifest.name.toUpperCase() + " - version " + manifest.version + "\n");

    initVariables();

    compileTarget();

    handleTasks();

    Sys.println("-- DONE --");
    Sys.exit(0);
  }

  /**
    Initialise all variables
   **/
  private function initVariables()
  {
    if(_project.define != null)
    {
      var defines : Array<PDefine> = _project.define;
      for(d in defines)
        Utils.setEnvironmentVar(d.name, d.value);
    }
  }

  /**

   **/
  private function compileTarget()
  {
    var targets : Array<PTarget> = _project.targets;
    for(t in targets)
    {
      if(t.hxml != null)
      {
        var hxml_file = Utils.getPath(t.hxml);
        var params : Array<String> = [hxml_file];

        // Gestion des conditions
        if(t.cond != null)
        {
          // on liste les conditions
          var conds = Reflect.fields(t.cond);
          for(c in conds)
          {
            if( !D.exists(c) ) continue;

            var add_data = Reflect.field(t.cond, c);
            var flags : Array<String> = add_data.flags;
            params = params.concat(flags);
          }
        }

        var hxCmd = new HaxeCommand(params);
        if(hxCmd.execute() > 0)
          exitTool();
      }

      Sys.println("");
    }
  }

  /**

   **/
  private function handleTasks()
  {
    var tasks : Array<PTask> = _project.tasks;
    for(t in tasks)
    {
      if(t.only != null && !D.exists(t.only)) continue;
      if(t.except != null && D.exists(t.except)) continue;

      var cl = Type.resolveClass("plugins." + t.plugin);
      if(cl != null)
      {
        var cl_inst : ITask = Type.createInstance(cl, t.params);
        if(cl_inst.execute() > 0)
          exitTool();
      }
      else
      {
        Sys.println("Plugin class plugins." + t.plugin + " not found");
        exitTool();
      }

      Sys.println("");
    }
  }

  private function exitTool()
  {
    Sys.println("-- FAILED --");
    Sys.exit(1);
  }

}

typedef PProject = {
  @:optional var define : Array<PDefine>;
  var targets : Array<PTarget>;
  @:optional var tasks : Array<PTask>;
  var manifest : PManifest;
}

typedef PDefine = {
  var name : String;
  var value : Dynamic;
}

typedef PTarget = {
  @:optional var hxml : String;
  @:optional var cond : Dynamic;
}

typedef PTask = {
  var plugin : String; // plugin name
  var params : Array<Dynamic>;
  @:optional var only : String;
  @:optional var except : String;
}

typedef PManifest = {
  var name : String;
  var version : String;
}
