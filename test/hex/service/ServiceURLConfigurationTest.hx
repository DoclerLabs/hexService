package hex.service;

import hex.service.ServiceConfigurationTest;
import hex.service.ServiceURLConfiguration;
import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ServiceURLConfigurationTest extends ServiceConfigurationTest
{
	@Test( "Test 'serviceURL' parameter passed to constructor" )
    public function testServiceURL() : Void
    {
        var serviceUrl : String = "url";
        var serviceConfiguration = new ServiceURLConfiguration( serviceUrl );

        Assert.equals( serviceUrl, serviceConfiguration.serviceUrl, "'serviceURL' property should be the same passed to constructor" );
    }
}