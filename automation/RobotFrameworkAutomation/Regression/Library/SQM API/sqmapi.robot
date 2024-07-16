*** Settings ***
Documentation     Operation to perform the feasibility check
Library           OperatingSystem
Library           String
Library           RequestsLibrary
Resource          ../Database/database.robot
Resource          ../XML/xml.robot
Resource          ../Json/json.robot
Resource          ../Csv/csv.robot
Library           Collections

*** Variables ***
${API_OPER_CREATEREQUEST}    /eoc/serviceQualificationManagement/v1/serviceQualification
&{MW_KPN_API}     HOST_INT=http://mw.int.itservices.lan:5180    HOST_UAT=http://mw.uat.itservices.lan:5180    API=/invoke/VTEOC.Incoming.Flows.WBA:receiveRequest    INT_PWD=YXBwLWVvYzphcHAtZW9j    UAT_PWD=YXBwLWVvYzp4WWFBOXVScG5zM2h4Q044dTVGdg==


*** Keywords ***
Perform Feasibility Check
    [Arguments]    ${fetchConnectionPointInfo}    ${postalCode}    ${houseNumber}    ${houseNumberExtension}
    [Documentation]    Invokes SQM API
    #Prepare SQM Request
    ${request}    Prepare SQM Request    ${fetchConnectionPointInfo}    ${postalCode}    ${houseNumber}    ${houseNumberExtension}
    log    ${fetchConnectionPointInfo}
    log    ${postalCode}
    log    ${houseNumber}
    log    ${houseNumberExtension}
    #Send SQM Request
    Create Session    eoc session    ${EOC_HOST}
    ${header}    Create Dictionary    Content-Type=application/json    Authorization=Basic ${EOC_API_AUTH}
    ${response}    POST On Session    eoc session    ${API_OPER_CREATEREQUEST}    data=${request}    headers=${header}
    Request Should Be Successful    ${response}
    [Return]    ${response.json()}

Prepare SQM Request
    [Arguments]    ${fetchConnectionPointInfo}    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    [Documentation]    Generates SQM payload
    #Prepare SQM payload
    ${SQM_Request}    Get File    ${CURDIR}/../../TestData/Common/TC/feasibilityRequest.json
    #Replace Fetch Connection Point Info in Request
    ${SQM_Request}    Replace String    ${SQM_Request}    DynamicVariable.FetchConnectionPointInfo    ${fetchConnectionPointInfo}
    #Replace Postcode in Request
    ${SQM_Request}    Replace String    ${SQM_Request}    DynamicVariable.PostCode    ${postCode}
    #Replace House Number in the request
    ${SQM_Request}    Replace String    ${SQM_Request}    DynamicVariable.HouseNumber    ${houseNumber}
    #Replace House Number Ext in the request
    ${SQM_Request}    Replace String    ${SQM_Request}    DynamicVariable.HousenumberExtension    ${houseNumberExtension}
    [Return]    ${SQM_Request}

Prepare FPI Request
    [Arguments]    ${PostCode}    ${HouseNumber}    ${HouseNumberExt}
    [Documentation]    Prepare the request for CIP \ API call towards KPN
    #Prepare CIP Request JSON
    ${FPI_Request}    Get File    ${CURDIR}/../../TestData/SQM_IP_ACCESS/TC/fpi_request.xml
    #Replace Postcode in Request
    ${PostCode}    Convert To String    ${PostCode}
    ${FPI_Request}    Replace String    ${FPI_Request}    DynamicVariable.PostCode    ${PostCode.replace(" ","")}
    #Replace House Number in the request
    ${FPI_Request}    Replace String    ${FPI_Request}    DynamicVariable.HouseNumber    ${HouseNumber}
    #Replace House Number Ext in the request
    ${FPI_Request}    Replace String    ${FPI_Request}    DynamicVariable.HousenumberExtension    ${HouseNumberExt}
    Log    ${FPI_Request}
    [Return]    ${FPI_Request}

Prepare CIP Request
    [Arguments]    ${PostCode}    ${HouseNumber}    ${HouseNumberExt}
    [Documentation]    Prepare the request for CIP \ API call towards KPN
    #Prepare CIP Request JSON
    ${CIP_Request}    Get File    ${CURDIR}/../../TestData/SQM_IP_ACCESS/TC/cip_request.xml
    #Replace Postcode in Request
    ${PostCode}    Convert To String    ${PostCode}
    ${CIP_Request}    Replace String    ${CIP_Request}    DynamicVariable.PostCode    ${PostCode.replace(" ","")}
    #Replace House Number in the request
    ${CIP_Request}    Replace String    ${CIP_Request}    DynamicVariable.HouseNumber    ${HouseNumber}
    #Replace House Number Ext in the request
    ${CIP_Request}    Replace String    ${CIP_Request}    DynamicVariable.HousenumberExtension    ${HouseNumberExt}
    Log    ${CIP_Request}
    [Return]    ${CIP_Request}

Perform FPI
    [Arguments]    ${postalCode}    ${houseNumber}    ${houseNumberExtension}
    [Documentation]    Sends CIP Request towards KPN
    #Get Environment specific MW[FPI] API Details
    ${mwDetails}    Get File    TestData/Common/Environment/Middleware_KPN.json
    ${mwDetailsJson}    evaluate    json.loads('''${mwDetails}''')    json
    ${mwEnv}    Set Variable    ${mwDetailsJson}[${ENV}]
    Set to Dictionary    ${mwEnv}    api    ${mwDetailsJson}[api]
    #Set The API Details
    ${MW_HOST}    Set Variable    ${mwEnv}[host]
    ${Auth}    Set Variable    ${mwEnv}[auth]
    ${MW_API}    Set Variable    ${mwEnv}[api][receiveRequest]
    #Prepare FPI Request Payload
    ${FPI_Request}    Prepare FPI Request    ${postalCode}    ${houseNumber}    ${houseNumberExtension}
    # Send CIP Request towards KPN
    #Create session with MW
    Create Session    eoc session    ${MW_HOST}
    #Prepare Header
    ${header}    Create Dictionary    Content-Type=text/xml    Authorization=Basic ${Auth}
    ${fpi_response}    POST On Session    eoc session    ${MW_API}    data=${FPI_Request}    headers=${header}
    Request Should Be Successful    ${fpi_response}
    ${fpi_response}    Parse Xml    ${fpi_response.text}
    [Return]    ${fpi_response}

Perform CIP
    [Arguments]    ${postalCode}    ${houseNumber}    ${houseNumberExtension}
    [Documentation]    Sends CIP Request towards KPN
    #Get Environment specific MW[CIP] API Details
    ${mwDetails}    Get File    TestData/Common/Environment/Middleware_KPN.json
    ${mwDetailsJson}    evaluate    json.loads('''${mwDetails}''')    json
    ${mwEnv}    Set Variable    ${mwDetailsJson}[${ENV}]
    Set to Dictionary    ${mwEnv}    api    ${mwDetailsJson}[api]
    #Set The API Details
    ${MW_HOST}    Set Variable    ${mwEnv}[host]
    ${Auth}    Set Variable    ${mwEnv}[auth]
    ${MW_API}    Set Variable    ${mwEnv}[api][receiveRequest]
    #Prepare CIP Request Payload
    ${CIP_Request}    Prepare CIP Request    ${postalCode}    ${houseNumber}    ${houseNumberExtension}
    # Send CIP Request towards KPN
    #Create session with MW
    Create Session    eoc session    ${MW_HOST}
    #Prepare Header
    ${header}    Create Dictionary    Content-Type=text/xml    Authorization=Basic ${Auth}
    ${cip_response}    POST On Session     eoc session    ${MW_API}    data=${CIP_Request}    headers=${header}
    Request Should Be Successful    ${cip_response}
    ${cip_response}    Parse Xml    ${cip_response.text}
    [Return]    ${cip_response}

Perform Failed Feasibility Check
    [Arguments]    ${fetchConnectionPointInfo}    ${postalCode}    ${houseNumber}    ${houseNumberExtension}
    [Documentation]    Invokes SQM API
    #Prepare SQM Request
    ${request}    Prepare SQM Request    ${fetchConnectionPointInfo}    ${postalCode}    ${houseNumber}    ${houseNumberExtension}
    #Send SQM Request
    Create Session    eoc session    ${EOC_HOST}
    ${header}    Create Dictionary    Content-Type=application/json    Authorization=Basic ${EOC_API_AUTH}
    ${response}    POST On Session     eoc session    ${API_OPER_CREATEREQUEST}    data=${request}    headers=${header}
    Log    ${response.json()}
    [Return]    ${response.json()}
