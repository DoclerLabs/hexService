package hex.service;

import hex.service.ServiceConfiguration;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ServiceConfigurationTest
{
	@Test( "Test 'serviceTimeout' default value from constructor" )
    public function testDefaultServiceTimeout() : Void
    {
        var serviceConfiguration = new ServiceConfiguration();

        Assert.equals( 5000, serviceConfiguration.serviceTimeout, "'serviceTimeout' property value should be 5000 by default" );
    }
	
	@Test( "Test 'serviceTimeout' parameter passed to constructor" )
    public function testServiceTimeout() : Void
    {
        var serviceTimeout : UInt = 400;
        var serviceConfiguration = new ServiceConfiguration( serviceTimeout );

        Assert.equals( serviceTimeout, serviceConfiguration.serviceTimeout, "'serviceTimeout' property should be the same passed to constructor" );
    }
}