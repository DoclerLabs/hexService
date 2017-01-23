package hex.service.stateless.http;

#if (!neko || haxe_ver >= "3.3")
import hex.event.MessageType;
import hex.service.stateless.IAsyncStatelessServiceListener;

/**
 * ...
 * @author Francis Bourre
 */
class MockHTTPServiceListener implements IAsyncStatelessServiceListener
{
	public var lastMessageTypeReceived 					: MessageType;
	public var lastServiceReceived 						: MockHTTPService;
	public var onServiceCompleteCallCount 				: Int = 0;
	public var onServiceFailCallCount 					: Int = 0;
	public var onServiceCancelCallCount 				: Int = 0;
	public var onServiceTimeoutCallCount 				: Int = 0;
	
	public function new()
	{
		
	}
	
	public function onServiceComplete( service : IAsyncStatelessService ) : Void 
	{
		this.lastServiceReceived = cast service;
		this.onServiceCompleteCallCount++;
	}
	
	public function onServiceFail( service : IAsyncStatelessService ) : Void 
	{
		this.lastServiceReceived = cast service;
		this.onServiceFailCallCount++;
	}
	
	public function onServiceCancel( service : IAsyncStatelessService ) : Void 
	{
		this.lastServiceReceived = cast service;
		this.onServiceCancelCallCount++;
	}
	
	public function onServiceTimeout( service : IAsyncStatelessService ) : Void 
	{
		this.lastServiceReceived = cast service;
		this.onServiceTimeoutCallCount++;
	}
	
	public function handleMessage( messageType : MessageType, service : MockHTTPService ) : Void 
	{
		this.lastMessageTypeReceived 	= messageType;
		this.lastServiceReceived 		= service;
	}
}
#end