*** Settings ***
Library           RequestsLibrary
Resource          ../Database/database.robot

*** Variables ***
&{SR_API_OPER_DICT}    GET_SERVICE=/eoc/sr/v1/service

*** Keywords ***
Get SR Service
    [Arguments]    ${cfsItem}
    [Documentation]    Returns Service from Service Registry based on service registry id
    Create Session    SR Get Service    ${EOC_HOST}
    # Send Get Request
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    GET On Session    SR Get Service    ${SR_API_OPER_DICT}[GET_SERVICE]/${cfsItem}[serviceId]    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json_object}    Set Variable    ${response.json()}
    [Return]    ${json_object}

SR Service Not Present
    [Arguments]    ${cfsItem}
    [Documentation]    Validates if for a given service, the service doesn't exists in Service Registry
    Create Session    SR Get Service    ${EOC_HOST}
    # Send Get Request
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    GET Request    SR Get Service    ${SR_API_OPER_DICT}[GET_SERVICE]/${cfsItem}[serviceId]    ${header}
    Status Should Be    404    ${response}
