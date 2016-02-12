package hex.service.monitor.http;

import haxe.Timer;
import hex.error.NullPointerException;
import hex.inject.Injector;
import hex.service.stateless.http.HTTPServiceConfiguration;
import hex.service.stateless.http.IHTTPService;
import hex.unittest.assertion.Assert;
import hex.unittest.runner.MethodRunner;

/**
 * ...
 * @author Francis Bourre
 */
class BasicHTTPServiceErrorStrategyTest
{
	public function new() 
	{
		
	}
	
	@Async( "Test that BasicHTTPServiceErrorStrategy instance recalls service 3 times" )
	public function testStrategyRetry() : Void
	{
		var serviceMonitor : BasicServiceMonitor = new BasicServiceMonitor();
		serviceMonitor.mapStrategy( MockHTTPService, new BasicHTTPServiceErrorStrategy( 3, 100 ) );
		serviceMonitor.mapStrategy( AnotherMockHTTPService, new BasicHTTPServiceErrorStrategy( 6, 50 ) );
		
		var injector : Injector = new Injector();
		injector.mapToValue( IServiceMonitor, serviceMonitor );
		injector.mapToType( MockHTTPService, MockHTTPService );
		injector.mapToType( AnotherMockHTTPService, AnotherMockHTTPService );
		
		MockHTTPService.serviceCallCount = 0;
		MockHTTPService.errorThrown = null;
		
		AnotherMockHTTPService.serviceCallCount = 0;
		AnotherMockHTTPService.errorThrown = null;
		
		var service : IHTTPService<HTTPServiceConfiguration> = injector.getOrCreateNewInstance( MockHTTPService );
		var anotherService : IHTTPService<HTTPServiceConfiguration> = injector.getOrCreateNewInstance( AnotherMockHTTPService );
		service.call();
		anotherService.call();
		
		Timer.delay( MethodRunner.asyncHandler( this._onCompleteTestStrategyRetry ), 400 );
	}
	
	function _onCompleteTestStrategyRetry() : Void
	{
		Assert.equals( 4, MockHTTPService.serviceCallCount, "service should have been called 3 times. One normal and 3 retry calls" );
		Assert.isInstanceOf( MockHTTPService.errorThrown, NullPointerException, "Error thrown after retries should be an instance of 'NullPointerException'" );
		
		Assert.equals( 7, AnotherMockHTTPService.serviceCallCount, "service should have been called 7 times. One normal and 6 retry calls" );
		Assert.isInstanceOf( AnotherMockHTTPService.errorThrown, NullPointerException, "Error thrown after retries should be an instance of 'NullPointerException'" );
	}
	
	@Async( "Test two different BasicHTTPServiceErrorStrategy instances at the same time" )
	public function testTwoStrategyRetryAtTheSameTime() : Void
	{
		var serviceMonitor : BasicServiceMonitor = new BasicServiceMonitor();
		serviceMonitor.mapStrategy( MockHTTPService, new BasicHTTPServiceErrorStrategy( 3, 100 ) );
		serviceMonitor.mapStrategy( AnotherMockHTTPService, new BasicHTTPServiceErrorStrategy( 6, 50 ) );
		
		var injector : Injector = new Injector();
		injector.mapToValue( IServiceMonitor, serviceMonitor );
		injector.mapToType( MockHTTPService, MockHTTPService );
		injector.mapToType( AnotherMockHTTPService, AnotherMockHTTPService );
		
		MockHTTPService.serviceCallCount = 0;
		MockHTTPService.errorThrown = null;
		
		AnotherMockHTTPService.serviceCallCount = 0;
		AnotherMockHTTPService.errorThrown = null;
		
		var service : IHTTPService<HTTPServiceConfiguration> = injector.getOrCreateNewInstance( MockHTTPService );
		var anotherService : IHTTPService<HTTPServiceConfiguration> = injector.getOrCreateNewInstance( AnotherMockHTTPService );
		service.call();
		anotherService.call();
		
		Timer.delay( MethodRunner.asyncHandler( this._onCompleteTestTwoStrategyRetryAtTheSameTime ), 400 );
	}
	
	function _onCompleteTestTwoStrategyRetryAtTheSameTime() : Void
	{
		Assert.equals( 4, MockHTTPService.serviceCallCount, "service should have been called 3 times. One normal and 3 retry calls" );
		Assert.isInstanceOf( MockHTTPService.errorThrown, NullPointerException, "Error thrown after retries should be an instance of 'NullPointerException'" );
		
		Assert.equals( 7, AnotherMockHTTPService.serviceCallCount, "service should have been called 7 times. One normal and 6 retry calls" );
		Assert.isInstanceOf( AnotherMockHTTPService.errorThrown, NullPointerException, "Error thrown after retries should be an instance of 'NullPointerException'" );
	}
}