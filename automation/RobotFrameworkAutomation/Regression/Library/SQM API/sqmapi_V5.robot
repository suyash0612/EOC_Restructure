*** Settings ***
Documentation     Operation to perform the feasibility check ACPE
Library           OperatingSystem
Library           String
Library           RequestsLibrary
Resource          ../Database/database.robot
Resource          ../XML/xml.robot
Resource          ../Json/json.robot
Resource          ../Csv/csv.robot
Library           Collections
Library           JSONLibrary

*** Variables ***
${API_OPER_CREATEREQUEST}    /eoc/serviceQualificationManagement/v5/serviceQualification
&{ACPE_API}       HOST_INT=http://postcodecheck.int.tele2portal.com    HOST_UAT=http://postcodecheck.uat.tele2portal.com

*** Keywords ***
Perform Feasibility Check
    [Arguments]    ${fetchConnectionPointInfo}    ${postalCode}    ${houseNumber}    ${houseNumberExtension}    ${serviceSpecificationName}=CFS_IP_ACCESS     ${connectionPointIdentifier}=${EMPTY}
    [Documentation]    Invokes SQM API - V5
    ${API_OPER_CREATEREQUEST}  Set Variable    /eoc/serviceQualificationManagement/v5/serviceQualification
    #Prepare SQM Request
    ${request}    sqmapi_V5.Prepare SQM Request    ${fetchConnectionPointInfo}    ${postalCode}    ${houseNumber}    ${houseNumberExtension}    ${serviceSpecificationName}      ${connectionPointIdentifier}
    #Send SQM Request
    log    ${EOC_HOST}
    Create Session    eoc session    ${EOC_HOST}
    ${header}    Create Dictionary    Content-Type=application/json    Authorization=Basic ${EOC_API_AUTH}
    ${response}    POST On Session     eoc session    ${API_OPER_CREATEREQUEST}    data=${request}    headers=${header}
    Request Should Be Successful    ${response}
    [Return]    ${response.json()}

Prepare SQM Request
    [Arguments]    ${fetchConnectionPointInfo}    ${postCode}    ${houseNumber}    ${houseNumberExtension}     ${serviceSpecificationName}      ${connectionPointIdentifier}
    [Documentation]    Generates SQM payload
    #Prepare SQM payload
    ${SQM_Request}    Get File    ${WORKSPACE}/TestData/Common/TC/feasibilityRequest_V5.json
    #Replace Fetch Connection Point Info in Request
    ${SQM_Request}    Replace String    ${SQM_Request}    DynamicVariable.FetchConnectionPointInfo    ${fetchConnectionPointInfo}
    #Replace Postcode in Request
    ${SQM_Request}    Replace String    ${SQM_Request}    DynamicVariable.PostCode    ${postCode}
    #Replace House Number in the request
    ${SQM_Request}    Replace String    ${SQM_Request}    DynamicVariable.HouseNumber    ${houseNumber}
    #Replace House Number Ext in the request
    ${SQM_Request}    Replace String    ${SQM_Request}    DynamicVariable.HousenumberExtension    ${houseNumberExtension}
    #Replace Service Specification Name in the request
    ${SQM_Request}    Replace String    ${SQM_Request}    DynamicVariable.ServiceSpecificationName    ${serviceSpecificationName}
    #Replace Connection Point Identifier if specified in the request
    ${SQM_Request}    Replace String    ${SQM_Request}    DynamicVariable.ConnectionPointIdentifier   ${connectionPointIdentifier}
    [Return]    ${SQM_Request}

Prepare ACPE Request
    [Arguments]    ${PostCode}    ${HouseNumber}    ${HouseNumberExt}   ${TechnologyTypes}
    [Documentation]    Prepare the request for ACPE feasibility
    #Prepare ACPE payload
    ${ACPE_Request}    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/acpe_request.json
    #Replace Postcode in Request
    ${ACPE_Request}    Replace String    ${ACPE_Request}    DynamicVariable.Zipcode    ${PostCode}
    #Replace House Number in the request
    ${ACPE_Request}    Replace String    ${ACPE_Request}    DynamicVariable.HouseNumber    ${houseNumber}
    #Replace House Number Ext in the request
    ${ACPE_Request}    Replace String    ${ACPE_Request}    DynamicVariable.Extension    ${HouseNumberExt}
    #Replace TechnologyTypes in the request if passed
    ${ACPE_Request}    Replace String    ${ACPE_Request}    DynamicVariable.TechnologyTypes    ${TechnologyTypes}
    Log    ${ACPE_Request}
    [Return]    ${ACPE_Request}

Perform ACPE
    [Arguments]    ${postalCode}    ${houseNumber}    ${houseNumberExtension}     ${TechnologyTypes}=VVDSL","VDSL","GoF","GPON","XGSPON
    [Documentation]    Sends feasibility Request towards ACPE
    #Get Environment specific ACPE API Details
    ${acpeDetails}    Get File    TestData/Common/Environment/ACPE.json
    ${acpeDetailsJson}    evaluate    json.loads('''${acpeDetails}''')    json
    ${acpeEnv}    Set Variable    ${acpeDetailsJson}[${ENV}]
    Set to Dictionary    ${acpeEnv}    api    ${acpeDetailsJson}[api]
    #Set The API Details
    ${ACPE_HOST}    Set Variable    ${acpeEnv}[host]
    #    ${Auth}    Set Variable    ${acpeEnv}[auth]
    ${ACPE_API}    Set Variable    ${acpeEnv}[api][receiveRequest]
    #Prepare ACPE Request Payload
    ${ACPE_Request}    sqmapi_V5.Prepare ACPE Request    ${postalCode}    ${houseNumber}    ${houseNumberExtension}     ${TechnologyTypes}
    #Create session with ACPE
    Create Session    eoc session    ${ACPE_HOST}
    #Prepare Header
    ${header}    Create Dictionary    Content-Type=application/json
    ${acpe_response}    POST On Session     eoc session    ${ACPE_API}    data=${ACPE_Request}    headers=${header}
    Request Should Be Successful    ${acpe_response}
    log    ${acpe_response.json()}
    #${fpi_response}    Parse JSON    ${fpi_response.text}
    [Return]    ${acpe_response.json()}

Perform Failed Feasibility Check
    [Arguments]    ${fetchConnectionPointInfo}    ${postalCode}    ${houseNumber}    ${houseNumberExtension}    ${serviceSpecificationName}=CFS_IP_ACCESS     ${connectionPointIdentifier}=${EMPTY}
    [Documentation]    Invokes SQM API - V5
    #Prepare SQM Request
    ${request}    Prepare SQM Request    ${fetchConnectionPointInfo}    ${postalCode}    ${houseNumber}    ${houseNumberExtension}     ${serviceSpecificationName}    ${connectionPointIdentifier}
    #Send SQM Request
    Create Session    eoc session    ${EOC_HOST}
    ${header}    Create Dictionary    Content-Type=application/json    Authorization=Basic ${EOC_API_AUTH}
    ${response}    POST On Session     eoc session    ${API_OPER_CREATEREQUEST}    data=${request}    headers=${header}
    Log    ${response.json()}
    [Return]    ${response.json()}
