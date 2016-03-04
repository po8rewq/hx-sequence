package;

class Main
{
  public static function main()
  {
    new mcli.Dispatch(Sys.args()).dispatch(new Sequence());
  }
}
