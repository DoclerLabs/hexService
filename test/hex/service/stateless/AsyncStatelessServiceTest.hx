package hex.service.stateless;

import hex.error.IllegalStateException;
import hex.error.UnsupportedOperationException;
import hex.event.MessageType;
import hex.service.ServiceConfiguration;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class AsyncStatelessServiceTest
{
	public var service : MockAsyncStatelessService;
	
	@Before
    public function setUp() : Void
    {
        this.service = new MockAsyncStatelessService();
    }

    @After
    public function tearDown() : Void
    {
		this.service.release();
        this.service = null;
    }
	
	@Test( "test result accessors" )
	public function testResult() : Void
	{
		this.service.testSetResult( "result" );
		Assert.equals( "result", this.service.getResult(), "result getter should provide result setted value" );
	}
	
	@Test( "test result accessors with parser" )
	public function testResultWithParser() : Void
	{
		this.service.setParser( new MockParser() );
		this.service.testSetResult( 5 );
		Assert.equals( 6, this.service.getResult(), "result getter should provide result parsed value" );
	}
	
	@Test( "Test configuration accessors" )
    public function testConfigurationAccessors() : Void
    {
        var configuration = new ServiceConfiguration();

		Assert.isNull( this.service.getConfiguration(), "configuration should be null by default" );
		
		this.service.setConfiguration( configuration );
        Assert.equals( configuration, service.getConfiguration(), "configuration should be retrieved from getter" );
        Assert.equals( 5000, service.getConfiguration().serviceTimeout, "'serviceTimeout' value should be 5000" );
		
		this.service.timeoutDuration = 100;
		Assert.equals( 100, service.getConfiguration().serviceTimeout, "'serviceTimeout' value should be 100" );
    }
	
	@Test( "Test timeoutDuration accessors" )
    public function testTimeoutDurationAccessors() : Void
    {
		Assert.equals( 100, service.timeoutDuration, "'serviceTimeout' value should be 100" );
		this.service.timeoutDuration = 200;
		Assert.equals( 200, service.timeoutDuration, "'serviceTimeout' value should be 200" );
		
		#if !flash
		this.service.call();
		Assert.setPropertyThrows( IllegalStateException, this.service, "timeoutDuration", 40, "'timeoutDuration' call should throw IllegalStateException" );
		#end
	}
	
	@Test( "test call" )
	public function testCall() : Void
	{
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		service.call();
		
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return true" );
		Assert.isTrue( this.service.isRunning, "'isRunning' should return true" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		Assert.methodCallThrows( IllegalStateException, this.service, this.service.call, [], "service called twice should throw IllegalStateException" );
	}
	
	@Test( "test release" )
	public function testRelease() : Void
	{
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		this.service.release();
		
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isTrue( this.service.isCancelled, "'isCancelled' should return true" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		Assert.methodCallThrows( IllegalStateException, this.service, this.service.call, [], "service should throw IllegalStateException when called after release" );
	}
	
	@Test( "Test handleCancel" )
    public function testHandleCancel() : Void
    {
		var handler 		= new MockStatelessServiceListener();
		var anotherHandler 	= new MockStatelessServiceListener();
		
		this.service.addHandler( StatelessServiceMessage.CANCEL, handler.onServiceCancel );
		
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		service.handleCancel();
		
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return true" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isTrue( this.service.isCancelled, "'isCancelled' should return true" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		Assert.isTrue( this.service.isCancelled, "'isCancelled' property should return true" );
		Assert.methodCallThrows( IllegalStateException, this.service, this.service.handleCancel, [], "StatelessService should throw IllegalStateException when calling cancel twice" );
		
		Assert.equals( 1, handler.onServiceCancelCallCount, "'handler' callback should be triggered once" );
		
		Assert.equals( this.service, handler.lastServiceReceived, "Service received by handler should be AsyncStatelessService instance" );
		//Assert.equals( StatelessServiceMessage.CANCEL, handler.lastEventReceived.type, "'event.type' received by handler should be StatelessServiceEventType.CANCEL" );
		
		service.addHandler( StatelessServiceMessage.CANCEL, anotherHandler.onServiceCancel );
		Assert.equals( 0, anotherHandler.onServiceCancelCallCount, "'post-handler' callback should not be triggered" );
    }
	
	@Test( "Test handleComplete" )
    public function testHandleComplete() : Void
    {
		var handler 		= new MockStatelessServiceListener();
		var anotherHandler 	= new MockStatelessServiceListener();
		
		this.service.addHandler( StatelessServiceMessage.COMPLETE, handler.onServiceComplete );
		
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		this.service.handleComplete();
		
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return true" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isTrue( this.service.hasCompleted, "'hasCompleted' property should return true" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		Assert.methodCallThrows( IllegalStateException, this.service, this.service.handleComplete, [], "StatelessService should throw IllegalStateException when calling cancel twice" );
		
		Assert.equals( 1, handler.onServiceCompleteCallCount, "'handler' callback should be triggered once" );

		Assert.equals( this.service, handler.lastServiceReceived, "Service received by handler should be AsyncStatelessService instance" );
		//Assert.equals( StatelessServiceMessage.COMPLETE, handler.lastEventReceived.type, "'event.type' received by handler should be StatelessServiceEventType.COMPLETE" );
		
		service.addHandler( StatelessServiceMessage.COMPLETE, anotherHandler.onServiceComplete );
		Assert.equals( 0, anotherHandler.onServiceCompleteCallCount, "'post-handler' callback should not be triggered" );
    }
	
	@Test( "Test handleFail" )
    public function testHandleFail() : Void
    {
		var handler 		= new MockStatelessServiceListener();
		var anotherHandler 	= new MockStatelessServiceListener();
		
		this.service.addHandler( StatelessServiceMessage.FAIL, handler.onServiceFail );
		
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		this.service.handleFail();
		
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return true" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isTrue( this.service.hasFailed, "'hasFailed' property should return true" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		Assert.methodCallThrows( IllegalStateException, this.service, this.service.handleFail, [], "StatelessService should throw IllegalStateException when calling cancel twice" );

		Assert.equals( 1, handler.onServiceFailCallCount, "'handler' callback should be triggered once" );
		
		Assert.equals( this.service, handler.lastServiceReceived, "Service received by handler should be AsyncStatelessService instance" );
		//Assert.equals( StatelessServiceMessage.FAIL, handler.lastEventReceived.type, "'event.type' received by handler should be StatelessServiceEventType.FAIL" );
		
		this.service.addHandler( StatelessServiceMessage.FAIL, anotherHandler.onServiceFail );
		Assert.equals( 0, anotherHandler.onServiceFailCallCount, "'post-handler' callback should not be triggered" );
    }
	
	@Test( "test timeout" )
	public function testTimeout() : Void
	{
		var handler 		= new MockStatelessServiceListener();
		var anotherHandler 	= new MockStatelessServiceListener();
		
		this.service.addHandler( AsyncStatelessServiceMessage.TIMEOUT, handler.onServiceTimeout );
		
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' property should return false" );
		this.service.timeoutDuration = 0;
		this.service.call();
		Assert.isTrue( this.service.hasTimeout, "'hasTimeout' property should return true" );

		Assert.equals( 1, handler.onServiceTimeoutCallCount, "'handler' callback should be triggered once" );

		Assert.equals( this.service, handler.lastServiceReceived, "Service received by handler should be AsyncStatelessService instance" );
		//Assert.equals( AsyncStatelessServiceMessage.TIMEOUT, handler.lastEventReceived.type, "'event.type' received by handler should be AsyncStatelessServiceEventType.TIMEOUT" );
		
		this.service.addHandler( AsyncStatelessServiceMessage.TIMEOUT, anotherHandler.onServiceTimeout );
		Assert.equals( 0, anotherHandler.onServiceTimeoutCallCount, "'post-handler' callback should not be triggered" );
	}
	
	@Test( "Test _getRemoteArguments call without override" )
    public function test_getRemoteArgumentsCall() : Void
    {
		Assert.methodCallThrows( UnsupportedOperationException, this.service, this.service.call_getRemoteArguments, [], "'_getRemoteArguments' call should throw an exception" );
	}
	
	@Test( "Test _reset call" )
    public function test_resetCall() : Void
    {
		this.service.call();
		
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return true" );
		Assert.isTrue( this.service.isRunning, "'isRunning' should return true" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
		
		service.call_reset();
		
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasTimeout, "'hasTimeout' should return false" );
	}
}

private class MockParser
{
	public function new()
	{
		
	}

	public function parse( serializedContent : Dynamic, target : Dynamic = null ) : Dynamic 
	{
		return serializedContent + 1;
	}
}

private class MockStatelessServiceListener
{
	public var lastMessageTypeReceived 					: MessageType;
	public var lastServiceReceived 						: MockAsyncStatelessService;
	public var onServiceCompleteCallCount 				: Int = 0;
	public var onServiceFailCallCount 					: Int = 0;
	public var onServiceCancelCallCount 				: Int = 0;
	public var onServiceTimeoutCallCount 				: Int = 0;
	
	public function new()
	{
		
	}
	
	public function onServiceComplete( service : MockAsyncStatelessService ) : Void 
	{
		this.lastServiceReceived = service;
		this.onServiceCompleteCallCount++;
	}
	
	public function onServiceFail( service : MockAsyncStatelessService ) : Void 
	{
		this.lastServiceReceived = service;
		this.onServiceFailCallCount++;
	}
	
	public function onServiceCancel( service : MockAsyncStatelessService ) : Void 
	{
		this.lastServiceReceived = service;
		this.onServiceCancelCallCount++;
	}
	
	public function onServiceTimeout( service : MockAsyncStatelessService ) : Void 
	{
		this.lastServiceReceived = service;
		this.onServiceTimeoutCallCount++;
	}
	
	public function handleMessage( messageType : MessageType, service : MockAsyncStatelessService ) : Void 
	{
		this.lastMessageTypeReceived 	= messageType;
		this.lastServiceReceived 		= service;
	}
}