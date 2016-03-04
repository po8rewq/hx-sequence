package plugins;

import sys.io.File;

class Copy implements ITask
{
  var _src : String;
  var _dest : String;

  public function new(pSrc: String, pDest: String)
  {
    _src = Utils.getPath(pSrc);
    _dest = Utils.getPath(pDest);
  }

  public function execute():Int
  {
    Sys.println("Copy " + _src + " to " + _dest);
    try{
      File.copy(_src, _dest);
      return 0;
    }catch ( error:Dynamic ){
      Sys.println("Can't copy file " + _src + " to " + _dest);
      // Sys.exit(1);
      return 1;
    }
    return 1;
  }
}
