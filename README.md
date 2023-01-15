 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/swagger-validator-cli)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-swagger-validator-cli&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-swagger-validator-cli)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-swagger-validator-cli&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-swagger-validator-cli)

# iris swagger validator client

This is an ObjectScript client for [swagger validator tools](https://validator.swagger.io/).  


## Description

This is a client only,  there is no validation logic in this library.  
It uses [validator.swagger.io](https://validator.swagger.io/).  

Currently Version 0.0.1, only these services are implemented :  

 * GET Parse.  
 * POST Parse.  

It's also possible to use a local instance of the swagger validator.  
See the documentation on [swagger-parser GitHub repository](https://github.com/swagger-api/swagger-parser) to start a local docker container.

## Installation

Terminal IRIS
```
zpm "install swagger-validator-cli"
```

## Usage

Example of using "Parse" operation with an URL:  

```ObjectScript
    Set webValidator = ##class(dc.swaggervalidatorcli.WebSwaggerValidator).%New()
    Set queryParameters("flatten")="true", queryParameters("url")="https://validator.swagger.io/validator/openapi.json"
    Set sc = webValidator.ParseByUrl(.queryParameters, .OpenAPIV3)
    If ''sc Do ##class(%JSON.Formatter).%New().Format(OpenAPIV3)
```


Example of using "Parse" operation with specification in a file.   

```ObjectScript
    Set webValidator = ##class(dc.swaggervalidatorcli.WebSwaggerValidator).%New()
    Set webValidator.specification = ##class(dc.swaggervalidatorcli.WebSwaggerValidator).fileToDynamic("/home/irisowner/irisdev/spec.json")
    Set queryParameters("flatten")="true"
    Set sc = webValidator.Parse(.queryParameters, .OpenAPIV3)
    If ''sc Do ##class(%JSON.Formatter).%New().Format(OpenAPIV3)
```

If you prefer use your own swagger validator instance instead of public REST services, set these nodes with your configuration : 

```ObjectScript
    Set ^swaggervalidator("ValidatorURL") = "https://validator.swagger.io/"
    Set ^swaggervalidator("Port") = "443"
    Set ^swaggervalidator("SSLConfig") = "default"
```


## Docker Installation 

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/lscalese/iris-swagger-validator-cli
```

Open the terminal in this directory and call the command to build and run InterSystems IRIS in container:

```
$ docker-compose up -d
```

If you have an error: 

```
iris_1  | terminate called after throwing an instance of 'std::runtime_error'
iris_1  |   what():  Unable to find/open file iris-main.log in current directory /home/irisowner/irisdev
```

It's probleme with right to create the iris-main.log file in the current directory.  

Try:
```
touch iris-main.log
chmod 777 iris-main.log
```


To open IRIS Terminal do:

```
$ docker-compose exec iris iris session iris -U IRISAPP
```

To exit the terminal, do any of the following:

```
Enter HALT or H (not case-sensitive)
```