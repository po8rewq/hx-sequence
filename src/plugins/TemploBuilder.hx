package plugins;

import sys.FileSystem;
import haxe.io.Path;

class TemploBuilder extends Execute
{
  var _destDir : String;
  var _srcDir : String;

  var _macro_file : String;

  public function new(pTemploExec: String, pTarget: String, pSrc: String, pDest: String, ?pMacroFile: String)
  {
    _destDir = pDest;
    _srcDir = pSrc;

    var params = new Array<String>();
    if(Type.createEnum(TemploTarget, pTarget) == TemploTarget.PHP)
      params.push("-php");

    if(pMacroFile != null)
    {
      _macro_file = pMacroFile;
      params.push("-macros");
      params.push(_macro_file);
    }

    if(pSrc != "")
    {
      params.push("-cp");
      params.push(_srcDir);
    }

    params.push("-output");
    params.push(_destDir);

    // attention au layout.html

    super(pTemploExec, params.concat(getTemplates(_srcDir)));
  }

  /**
   * Get all template to compile
   */
  private function getTemplates(pDir: String): Array<String>
  {
    var result = new Array<String>();
    var files = FileSystem.readDirectory(pDir);
    for(f in files)
    {
      if(f == null || f == _macro_file || f.charAt(0) == "_") continue;

      var file = Path.join([pDir, f]);
      if( FileSystem.isDirectory( file ) )
        result = result.concat( getTemplates( file ) )
      else
      {
        var dir = _srcDir + (_srcDir.charAt(_srcDir.length - 1) != "/" ? "/" : "");
        result.push( StringTools.replace(file, dir, '') );
      }
    }
    return result;
  }

  public override function execute():Int
  {
    // clean le dossier de destination
    Sys.println("Clean template directory");
    var tpls = FileSystem.readDirectory(_destDir);
    for(f in tpls)
      FileSystem.deleteFile( Path.join([_destDir, f]) );

    return super.execute();
  }

}

enum TemploTarget {
  PHP;
  NEKO;
}
