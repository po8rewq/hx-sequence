package plugins;

import sys.io.Process;

class Execute implements ITask
{
  var _command : String;
  var _params : Array<String>;

  public function new(pCommand: String, pParams: Array<String>)
  {
    _command = Utils.getPath(pCommand);
    _params = new Array();
    for(p in pParams)
      _params.push( Utils.getPath(p) );
  }

  public function execute():Int
  {
    Sys.println("Execute " + _command + " " + _params);
    try{
      var process = new Process(_command, _params);

      try
			{
				while (true)
				{
					Sys.sleep(0.01);
					var output = process.stdout.readLine();
          Sys.println("   " + output);
				}
			}
			catch (e:haxe.io.Eof) {}

      var exitCode = process.exitCode();
			var errString = process.stderr.readAll().toString();
			if (exitCode > 0 || errString.length > 0)
				Sys.println("   " + errString);

			return exitCode;
    }catch ( error:Dynamic ){
      Sys.println(error);
      // Sys.println("   Can't execute this command with parameters " + _params);
      // Sys.exit(1);
      return 1;
    }
    return 1;
  }
}
