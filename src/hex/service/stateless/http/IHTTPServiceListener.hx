package hex.service.stateless.http;
import hex.service.ServiceConfiguration;

/**
 * ...
 * @author Francis Bourre
 */
interface IHTTPServiceListener<ServiceConfigurationType:ServiceConfiguration>
{
	function onServiceComplete( service : IHTTPService<ServiceConfigurationType> ) : Void;
	function onServiceFail( service : IHTTPService<ServiceConfigurationType> ) : Void;
	function onServiceCancel( service : IHTTPService<ServiceConfigurationType> ) : Void;
	function onServiceTimeout( service : IHTTPService<ServiceConfigurationType> ) : Void;
}