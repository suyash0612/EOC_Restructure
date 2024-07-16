*** Settings ***
Resource          ../../OM/om.robot
Resource          ../../Message Log/messagelog.robot
Resource          ../../XML/xml.robot
Resource          ../../Data Order/dataorder.robot
Library           JSONLibrary
Library           String
Resource          ../../Json/json.robot
Resource          ../../SR API/srapi.robot

*** Keywords ***
CFS Multi Room WiFi Customer ADD Register Customer Validation
    [Arguments]    ${order}    ${item}    ${taiName}
    [Documentation]    Validates Plume Register Customer
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    ${API_OPERATION}[REGISTER_CUSTOMER]
    ${request_json}    evaluate    json.loads('''${request}''')    json
    #Partner Id
    ${partnerId}    Set Variable    5e56a758caa66c59220f0f9d
    #Validate Payload
    #Validate Customer Id
    ${customer}    Get Order Related Party    ${order}    Customer
    JSON Validate Element by Value    ${request_json}    $.accountId    ${customer}[reference]
    #Validate Partner Id
    JSON Validate Element by Value    ${request_json}    $.partnerId    ${partnerId}
    #Validate Group Id
    JSON Validate Element by Value    ${request_json}    $.groupIds[0]    ${partnerId}
    #Validate Email
    ${email}    Set Variable    sp${partnerId}_${customer}[reference]@plumewifi.com
    JSON Validate Element by Value    ${request_json}    $.email    ${email}
    #Validate Name
    JSON Validate Element by Value    ${request_json}    $.name    ${customer}[partyDescription]

CFS Muti Room WiFi Customer ADD SR Validation
    [Arguments]    ${item}    ${srState}    ${relatedItems}
    [Documentation]    Validates CFS SR state and relations
    ${srService}    Get SR Service    ${item}
    #Validate SR Status
    JSON Validate Element by Value    ${srService}    $.statuses[0].status    ${srState}
    #Validate Relationships
    ${relationsLength}    Get Length    ${relatedItems}
    FOR    ${INDEX}    IN RANGE    0    ${relationsLength}
        ${relatedItem}    Set Variable    ${relatedItems}[${INDEX}]
        ${jsonPath}    Set Variable    $.serviceRelationships[?( @.service.id=="${relatedItem}[serviceId]")]
        ${jsonElement}    Get Value From Json    ${srService}    ${jsonPath}
        Should be Equal    ${jsonElement}[0][type]    ParentOf
        Should be Equal    ${jsonElement}[0][service][name]    ${relatedItem}[cfs]
    END
