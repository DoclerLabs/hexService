package hex.service.stateless;

#if (!neko || haxe_ver >= "3.3")
import hex.service.stateless.AsyncStatelessService;

/**
 * ...
 * @author Francis Bourre
 */
class MockAsyncStatelessService extends AsyncStatelessService
{
	public function new()
	{
		super();
	}
	
	public function call_getRemoteArguments() : Array<Dynamic> 
	{
		return this._getRemoteArguments();
	}
	
	public function call_reset() : Void 
	{
		this._reset();
	}
	
	public function testSetResult( result : Dynamic ) : Void
	{
		this._setResult( result );
	}
}
#end