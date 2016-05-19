package hex.service.stateless;

import hex.data.ServiceParser;
import hex.error.IllegalStateException;
import hex.error.UnsupportedOperationException;
import hex.event.MessageType;
import hex.service.ServiceConfiguration;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class StatelessServiceTest
{
	public var service : MockStatelessService;
	
	@Before
    public function setUp() : Void
    {
        this.service = new MockStatelessService();
    }

    @After
    public function tearDown() : Void
    {
        this.service = null;
    }
	
	@Test( "Test 'getConfiguration' accessor" )
    public function testGetConfiguration() : Void
    {
        var configuration = new ServiceConfiguration();

		Assert.isNull( this.service.getConfiguration(), "configuration should be null by default" );
		
		this.service.setConfiguration( configuration );
        Assert.equals( configuration, service.getConfiguration(), "configuration should be retrieved from getter" );
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
	
	@Test( "test call" )
	public function testCall() : Void
	{
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		
		service.call();
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return true" );
		Assert.isTrue( this.service.isRunning, "'isRunning' should return true" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		
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
		
		this.service.release();
		
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isTrue( this.service.isCancelled, "'isCancelled' should return true" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		
		Assert.methodCallThrows( IllegalStateException, this.service, this.service.call, [], "service should throw IllegalStateException when called after release" );
	}
	
	@Test( "Test handleCancel" )
    public function testHandleCancel() : Void
    {
		var handler 		= new MockStatelessServiceListener();
		var anotherHandler 	= new MockStatelessServiceListener();
		
		this.service.addHandler( StatelessServiceMessage.CANCEL, handler, handler.onServiceCancel );
		
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		
		service.handleCancel();
		
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return true" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isTrue( this.service.isCancelled, "'isCancelled' should return true" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		
		Assert.methodCallThrows( IllegalStateException, this.service, this.service.handleCancel, [], "StatelessService should throw IllegalStateException when calling cancel twice" );
		
		Assert.equals( 1, handler.onServiceCancelCallCount, "'handler' callback should be triggered once" );

		Assert.equals( this.service, handler.lastServiceReceived, "Service' received by handler should be StatelessService instance" );
		//Assert.equals( StatelessServiceEventType.CANCEL, handler.lastEventReceived.type, "'event.type' received by handler should be StatelessServiceEventType.CANCEL" );
		
		service.addHandler( StatelessServiceMessage.CANCEL, anotherHandler, anotherHandler.onServiceCancel );
		Assert.equals( 0, anotherHandler.onServiceCancelCallCount, "'post-handler' callback should not be triggered" );
    }
	
	@Test( "Test handleComplete" )
    public function testHandleComplete() : Void
    {
		var handler 		= new MockStatelessServiceListener();
		var anotherHandler 	= new MockStatelessServiceListener();
		
		this.service.addHandler( StatelessServiceMessage.COMPLETE, handler, handler.onServiceComplete );
		
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		
		this.service.handleComplete();
		
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return true" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isTrue( this.service.hasCompleted, "'hasCompleted' property should return true" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		
		Assert.methodCallThrows( IllegalStateException, this.service, this.service.handleComplete, [], "StatelessService should throw IllegalStateException when calling cancel twice" );
		
		Assert.equals( 1, handler.onServiceCompleteCallCount, "'handler' callback should be triggered once" );
		
		Assert.equals( this.service, handler.lastServiceReceived, "Service received by handler should be StatelessService instance" );
		//Assert.equals( StatelessServiceEventType.COMPLETE, handler.lastEventReceived.type, "'event.type' received by handler should be StatelessServiceEventType.COMPLETE" );
		
		service.addHandler( StatelessServiceMessage.COMPLETE, anotherHandler, anotherHandler.onServiceComplete );
		Assert.equals( 0, anotherHandler.onServiceCompleteCallCount, "'post-handler' callback should not be triggered" );
    }
	
	@Test( "Test handleFail" )
    public function testHandleFail() : Void
    {
		var handler 		= new MockStatelessServiceListener();
		var anotherHandler 	= new MockStatelessServiceListener();
		
		this.service.addHandler( StatelessServiceMessage.FAIL, handler, handler.onServiceFail );
		
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isFalse( this.service.hasFailed, "'hasFailed' property should return false" );
		
		this.service.handleFail();
		
		Assert.isTrue( this.service.wasUsed, "'wasUsed' should return true" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
		Assert.isTrue( this.service.hasFailed, "'hasFailed' property should return true" );
		
		Assert.methodCallThrows( IllegalStateException, this.service, this.service.handleFail, [], "StatelessService should throw IllegalStateException when calling cancel twice" );
		
		Assert.equals( 1, handler.onServiceFailCallCount, "'handler' callback should be triggered once" );

		Assert.equals( this.service, handler.lastServiceReceived, "Service received by handler should be StatelessService instance" );
		//Assert.equals( StatelessServiceEventType.FAIL, handler.lastEventReceived.type, "'event.type' received by handler should be StatelessServiceEventType.FAIL" );
		
		this.service.addHandler( StatelessServiceMessage.FAIL, anotherHandler, anotherHandler.onServiceFail );
		Assert.equals( 0, anotherHandler.onServiceFailCallCount, "'post-handler' callback should not be triggered" );
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
		
		service.call_reset();
		
		Assert.isFalse( this.service.wasUsed, "'wasUsed' should return false" );
		Assert.isFalse( this.service.isRunning, "'isRunning' should return false" );
		Assert.isFalse( this.service.hasCompleted, "'hasCompleted' should return false" );
		Assert.isFalse( this.service.isCancelled, "'isCancelled' should return false" );
	}
}

private class MockParser
{
	public function new()
	{
		
	}

	public function parse( serializedContent : Dynamic ) : Dynamic 
	{
		return serializedContent + 1;
	}
}

private class MockStatelessServiceListener
{
	public var lastMessageTypeReceived 					: MessageType;
	public var lastServiceReceived 						: MockStatelessService;
	public var onServiceCompleteCallCount 				: Int = 0;
	public var onServiceFailCallCount 					: Int = 0;
	public var onServiceCancelCallCount 				: Int = 0;
	
	public function new()
	{
		
	}
	
	public function onServiceComplete( service : MockStatelessService ) : Void 
	{
		this.lastServiceReceived = service;
		this.onServiceCompleteCallCount++;
	}
	
	public function onServiceFail( service : MockStatelessService ) : Void 
	{
		this.lastServiceReceived = service;
		this.onServiceFailCallCount++;
	}
	
	public function onServiceCancel( service : MockStatelessService ) : Void 
	{
		this.lastServiceReceived = service;
		this.onServiceCancelCallCount++;
	}
	
	public function handleMessage( messageType : MessageType, service : MockStatelessService ) : Void 
	{
		this.lastMessageTypeReceived 	= messageType;
		this.lastServiceReceived 		= service;
	}
}