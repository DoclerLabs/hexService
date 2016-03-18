package hex.service.monitor;

import hex.collection.HashMap;
import hex.core.HashCodeFactory;
import hex.error.Exception;
import hex.error.IllegalArgumentException;
import hex.log.Stringifier;
import hex.service.Service;
import hex.service.ServiceConfiguration;
import hex.service.monitor.http.BasicHTTPServiceErrorStrategy;
import hex.service.stateful.StatefulService;
import hex.service.stateless.http.HTTPService;
import hex.util.ClassUtil;

/**
 * ...
 * @author Francis Bourre
 */
@:rtti
class BasicServiceMonitor extends StatefulService<ServiceConfiguration> implements IServiceMonitor
{
	var _map : HashMap<Dynamic, Dynamic>;
	
	public function new() 
	{
		super();
		this._map = new HashMap();
	}
	
	override public function createConfiguration():Void 
	{
		
	}
	
	public function getStrategy<ServiceType:Service>( service : ServiceType ) : IServiceErrorStrategy<ServiceType>
	{
		var serviceClasses : Array<Class<Dynamic>> = ClassUtil.getInheritanceChainFrom( service );
		for ( serviceClass in serviceClasses )
		{
			if ( this._map.containsKey( serviceClass ) )
			{
				return this._map.get( serviceClass );
			}
		}
		
		return null;
	}
	
	public function mapStrategy<ServiceType:Service>( serviceClass : Class<ServiceType>, strategy : IServiceErrorStrategy<ServiceType> ) : Bool
	{
		if ( !this._map.containsKey( serviceClass ) )
		{
			this._map.put( serviceClass, strategy );
			return true;
		}

		throw new IllegalArgumentException( "mapStrategy failed with '" +  Stringifier.stringify( serviceClass ) + "'. this class was already mapped." );
	}
	
	function _handleFatalError<ServiceType:Service>( service : ServiceType, error : Exception ) : Void
	{
		this._compositeDispatcher.dispatch( ServiceMonitorMessage.FATAL, [ new ServiceMonitorMessage( service, error ) ] );
	}
}