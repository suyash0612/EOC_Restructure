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
CFS INTERNET DELETE Design and Assign Validation
    [Arguments]    ${order}    ${item}    ${related_ip_access_item}    ${taiName}
    [Documentation]    Validates EAI Design and Assign request
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[DESIGN_AND_ASSIGN]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    # Validate Service Instance ID for Order Item
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    ${objectId}    Get Service Item Characteristic    ${CFS_INTERNET}    eaiObjectId
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/serviceName/text()    ${objectId}
    # Validate Service Type
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/serviceType/text()    ipaccess:Internet
    # Validate Action
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/action/text()    DISCONNECT

CFS INTERNET DELETE Complete Validation
    [Arguments]    ${item}    ${taiName}
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[COMPLETE]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    # Validate Project Key
    ${projectKey}    Get Service Item Characteristic    ${item}    eaiProjectKey
    XML Validate Element by Value    ${request_xml}    //projectKey/keyValue/text()    ${projectKey}

CFS PIN DELETE Complete Validation
    [Arguments]    ${item}    ${taiName}
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[COMPLETE]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    # Validate Project Key
    ${projectKey}    Get Service Item Characteristic    ${item}    eaiProjectKey
    XML Validate Element by Value    ${request_xml}    //projectKey/keyValue/text()    ${projectKey}

CFS INTERNET DELETE SR Validation
    [Arguments]    ${item}    ${srState}    ${relatedItems}
    [Documentation]    Validates the information stored in SR
    ${srService}    Get SR Service    ${item}
    #Validate SR Status
    JSON Validate Element by Value    ${srService}    $.statuses[0].status    ${srState}
    #Validate Relationships
    ${relationsLength}    Get Length    ${relatedItems}
    FOR    ${INDEX}    IN RANGE    0    ${relationsLength}
        ${relatedItem}    Set Variable    ${relatedItems}[${INDEX}]
        ${jsonPath}    Set Variable    $.serviceRelationships[?( @.service.id=="${relatedItem}[services][0][serviceId]")]
        ${jsonElement}    Get Value From Json    ${srService}    ${jsonPath}
        Should be Equal    ${jsonElement}[0][type]    ReliesOn
        Should be Equal    ${jsonElement}[0][service][name]    ${relatedItem}[services][0][cfsSpecification]
    END
