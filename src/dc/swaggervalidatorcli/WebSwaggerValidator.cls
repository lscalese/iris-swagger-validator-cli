Class dc.swaggervalidatorcli.WebSwaggerValidator Extends %RegisteredObject
{

Property specification As %DynamicObject;

Parameter DEFAULTVALIDATOR = "https://validator.swagger.io";

Parameter SSLCONFIGURATION = "default";

Property ConverterURL As %String [ InitialExpression = {$Get(^swaggervalidator("ValidatorURL"), ..#DEFAULTVALIDATOR)} ];

Property SSLConfig As %String [ InitialExpression = {$Get(^swaggervalidator("SSLConfig"), ..#SSLCONFIGURATION)} ];

Property Port As %Integer [ InitialExpression = {$Get(^swaggervalidator("Port"))} ];

Property httpRequest As %Net.HttpRequest;

ClassMethod testByFile(path = "/home/irisowner/irisdev/spec.json") As %Status
{
    Set webValidator = ##class(dc.swaggervalidatorcli.WebSwaggerValidator).%New()
    Set webValidator.specification = ##class(dc.swaggervalidatorcli.WebSwaggerValidator).fileToDynamic("/home/irisowner/irisdev/spec.json")
    Set queryParameters("flatten")="true"
    Set sc = webValidator.Parse(.queryParameters, .OpenAPIV3)
    If $$$ISOK(sc) Do ##class(%JSON.Formatter).%New().Format(OpenAPIV3)
    Quit sc
}

ClassMethod testByUrl(url As %String = "https://validator.swagger.io/validator/openapi.json") As %Status
{
    Set webValidator = ##class(dc.swaggervalidatorcli.WebSwaggerValidator).%New()
    Set queryParameters("flatten")="true", queryParameters("url")=url
    Set sc = webValidator.ParseByUrl(.queryParameters, .OpenAPIV3)
    If $$$ISOK(sc) Do ##class(%JSON.Formatter).%New().Format(OpenAPIV3)
    Quit sc
}

/// see https://validator.swagger.io/ for documentation of all queryParameters.<br/>
Method Parse(ByRef queryParameters As %Binary, Output OpenAPIV3 As %DynamicObject) As %Status
{
    Set OpenAPIV3 = {}, sc = $$$OK
    Do:'$ISOBJECT(..httpRequest) ..initHttpRequestObject()

	Set ..httpRequest.ContentType = "application/json"
    Do ..specification.%ToJSON(..httpRequest.EntityBody)

    Set paramName = ""
    For  {
        Set paramName = $Order(queryParameters(paramName), 1, paramValue)
        Quit:paramName=""
        Do ..httpRequest.SetParam(paramName, paramValue)
    }

	$$$QuitOnError(..httpRequest.Send("POST", "/validator/parse"))

    #dim pHttpResponse As %Net.HttpResponse = ..httpRequest.HttpResponse
	
    Quit:pHttpResponse.StatusCode'="200" $$$ERROR(5001, "Https Status code "_pHttpResponse.StatusCode)

    Set OpenAPIV3 = {}.%FromJSON(pHttpResponse.Data)
    
    Quit sc
}

Method ParseByUrl(ByRef queryParameters As %Binary, Output OpenAPIV3 As %DynamicObject) As %Status
{
    Set OpenAPIV3 = {}, sc = $$$OK
    Do:'$ISOBJECT(..httpRequest) ..initHttpRequestObject()

	Set ..httpRequest.ContentType = "application/json"
    
    Set paramName = ""
    For  {
        Set paramName = $Order(queryParameters(paramName), 1, paramValue)
        Quit:paramName=""
        Do ..httpRequest.SetParam(paramName, paramValue)
    }

	$$$QuitOnError(..httpRequest.Send("GET", "/validator/parse"))

    #dim pHttpResponse As %Net.HttpResponse = ..httpRequest.HttpResponse
	
    Quit:pHttpResponse.StatusCode'="200" $$$ERROR(5001, "Https Status code "_pHttpResponse.StatusCode)

    Set OpenAPIV3 = {}.%FromJSON(pHttpResponse.Data)
    
    Quit sc
}

Method initHttpRequestObject()
{
    Set ..httpRequest = ##class(%Net.HttpRequest).%New()
    Set ..httpRequest.Server = $Piece(..ConverterURL, "://", 2)

	If ..ConverterURL [ "https:" {
        Do ..AddSSLConfig(..SSLConfig)
        Set ..httpRequest.Https = $$$YES
        Set ..httpRequest.SSLConfiguration = ..SSLConfig
    }

    Set:..Port'="" ..httpRequest.Port = ..Port
	Set ..httpRequest.ContentType = "application/json"
    ;Do ..httpRequest.SetHeader("accept", "application/json")
    Quit
}

ClassMethod fileToDynamic(path As %String) As %DynamicObject
{
    Set sc = $$$OK
    Set fileSpec = ##class(%Stream.FileCharacter).%New()
    $$$ThrowOnError(fileSpec.LinkToFile(path))
    Quit {}.%FromJSON(.fileSpec)
}

ClassMethod AddSSLConfig(name As %String)
{
    New $NAMESPACE
    set $namespace="%SYS" do:'##class(Security.SSLConfigs).Exists(name) ##class(Security.SSLConfigs).Create(name)
    Quit
}

}
