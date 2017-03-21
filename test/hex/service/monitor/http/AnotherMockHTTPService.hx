package hex.service.monitor.http;

import hex.error.Exception;
import hex.service.stateless.http.HTTPService;

/**
 * ...
 * @author Francis Bourre
 */
class AnotherMockHTTPService extends HTTPService
{
	public static var serviceCallCount : UInt 		= 0;
	public static var errorThrown 		: Exception = null;
	
	@Inject
	public var serviceMonitor : IServiceMonitor<IServiceErrorStrategy<AnotherMockHTTPService>>;
	
	public function new() 
	{
		super();
		
	}
	
	override public function createConfiguration():Void 
	{
		//
	}
	
	override function _onError( msg : String ) : Void
	{
		var e : Exception = new MockHTTPServiceException( msg );
		
		if ( this.serviceMonitor.getStrategy( this ).handleError( this, e ) )
		{
			this._reset();
			this.serviceMonitor.getStrategy( this ).retry( this );
		}
		else
		{
			AnotherMockHTTPService.errorThrown = e;
			
			//In real case the line below should be uncommented
			//super._onError( msg );
		}
	}
	
	override public function call() : Void
	{
		try
		{
			AnotherMockHTTPService.serviceCallCount++;
			super.call();
		}
		catch( e : Exception )
		{
			if ( this.serviceMonitor.getStrategy( this ).handleError( this, new MockHTTPServiceException( e.message ) ) )
			{
				this.serviceMonitor.getStrategy( this ).retry( this );
			}
			else
			{
				AnotherMockHTTPService.errorThrown = e;
			}
		}
	}
}