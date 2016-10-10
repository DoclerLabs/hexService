package hex.service.stateless.http;

/**
 * ...
 * @author Francis Bourre
 */
class HTTPServiceConfiguration extends ServiceURLConfiguration
{
	public var requestMethod            : HTTPRequestMethod;
	public var dataFormat               : String;
	public var parameters	            : HTTPServiceParameters;
	public var requestHeaders           : Array<HTTPRequestHeader>;
	public var parameterFactory         : IHTTPServiceParameterFactory;
	
	#if js
	public var async					: Bool = true;
	public var withCredentials			: Bool	= false;
	#end
		
	public function new( url : String = null, method : HTTPRequestMethod = HTTPRequestMethod.GET, dataFormat : String = "text", timeout : UInt = 5000 ) 
	{
		super( url, timeout );
		
		this.requestMethod 		= method;
        this.dataFormat 		= dataFormat;
		this.parameters 		= new HTTPServiceParameters();
		this.requestHeaders 	= [];
		this.parameterFactory 	= new DefaultHTTPServiceParameterFactory();
	}
}