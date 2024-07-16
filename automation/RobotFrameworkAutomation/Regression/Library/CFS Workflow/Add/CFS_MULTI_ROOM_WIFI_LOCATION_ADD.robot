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
CFS Multi Room WiFi Location ADD Register Customer Location Validation
    [Arguments]    ${order}    ${item}    ${taiName}
    [Documentation]    Validates Pume Add Customer Location
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    ${API_OPERATION}[REGISTER_CUSTOMER_LOCATION]
    ${request_json}    evaluate    json.loads('''${request}''')    json
    #Validate Payload
    #Validate Location name
    ${place}    Get Service Item Related Entity    ${item}    Place
    ${placeData}    Evaluate    json.loads('${place}[entity]')    json
    ${placeName}    Catenate    ${placeData}[street]    ${placeData}[houseNumber]
    ${placeName}    Run Keyword If    "${placeData}[houseNumberExtension]" != ""    Catenate    ${placeData}[houseNumberExtension],
    ...    ELSE    Set Variable    ${placeName},
    ${placeName}    Catenate    ${placeName}    ${placeData}[postcode],    ${placeData}[city]
    JSON Validate Element by Value    ${request_json}    $.name    ${placeName}

CFS Multi Room WiFi Location ADD Update Customer Location Validation
    [Arguments]    ${order}    ${item}    ${taiName}
    [Documentation]    Validates Pume Add Customer Location
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    ${API_OPERATION}[UPDATE_CUSTOMER_LOCATION]
    ${request_json}    evaluate    json.loads('''${request}''')    json
    #Validate Payload
    #Validate Service Id
    JSON Validate Element by Value    ${request_json}    $.serviceId    ${item}[serviceId]

CFS Muti Room WiFi Location ADD SR Validation
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
        Should be Equal    ${jsonElement}[0][type]    ReliesOn
        Should be Equal    ${jsonElement}[0][service][name]    ${relatedItem}[cfs]
    END
