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
CFS IP Access CGW ADD Design and Assign Validation
    [Arguments]    ${order}    ${item}    ${related_ip_access_item}    ${taiName}
    [Documentation]    Validates EAI Design and Assign request
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    ${API_OPERATION}[DESIGN_AND_ASSIGN]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    #Validate Customer Id
    ${customer}    Get Order Related Party    ${order}    Customer
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'customerId']/stringAttributeValue/text()    ${customer}[reference]
    # Validate Service Order ID
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'orderId']/stringAttributeValue/text()    ${order}[id]
    # Validate Service Instance ID
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'serviceInstanceId']/stringAttributeValue/text()    ${item}[serviceId]
    # Validate Service Instance ID for Order Item
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/serviceName/text()    ${item}[serviceId]
    # Validate Service Type
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/serviceType/text()    ipaccess:CgwEquipment
    # Validate Action
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/action/text()    ADD
    #Validate Connection point
    ${ConnectionPoint}    Get Service Item Related Entity    ${related_ip_access_item}    ConnectionPoint
    ${ConnectionPointData}    Evaluate    json.loads('${ConnectionPoint}[entity]')    json
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'postcode']/stringAttributeValue/text()    ${ConnectionPointData}[postcode]
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'houseNumber']/stringAttributeValue/text()    ${ConnectionPointData}[houseNumber]
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'country']/stringAttributeValue/text()    ${ConnectionPointData}[country]
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'city']/stringAttributeValue/text()    ${ConnectionPointData}[city]
    #Validate Vendor
    ${vendor}    Get Service Item Characteristic    ${item}    vendor
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'vendor']/stringAttributeValue/text()    ${vendor}
    #Validate Model
    ${model}    Get Service Item Characteristic    ${item}    model
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'model']/stringAttributeValue/text()    ${model}

CFS IP Access CGW ADD Fetch Validation
    [Arguments]    ${item}    ${taiName}
    [Documentation]    Validates Fetch Request towards EAI
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    ${API_OPERATION}[FETCH]
    ${request_xml}    Parse Xml    ${request}
    ${projectKey}    Get Service Item Characteristic    ${item}    eaiProjectKey
    #Validate Project Key
    XML Validate Element by Value    ${request_xml}    //projectKey/keyValue/text()    ${projectKey}
    # Validate fetchTopologyElements
    XML Validate Element by Value    ${request_xml}    //serviceGraphFetchSpec/fetchTopologyElements/text()    true
    # Validate outputView
    XML Validate Element by Value    ${request_xml}    //serviceGraphFetchSpec/outputView/text()    ACTIVATION
    # Validate calculateServiceElementAction
    XML Validate Element by Value    ${request_xml}    //serviceGraphFetchSpec/calculateServiceElementAction /text()    true
    # Validate \ fetchServiceComponents
    XML Validate Element by Value    ${request_xml}    //serviceGraphFetchSpec/fetchServiceComponents/text()    true

CFS IP Access CGW ADD Complete Project Validation
    [Arguments]    ${item}    ${taiName}
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    ${API_OPERATION}[COMPLETE]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    # Validate Project Key
    ${projectKey}    Get Service Item Characteristic    ${item}    eaiProjectKey
    XML Validate Element by Value    ${request_xml}    //projectKey/keyValue/text()    ${projectKey}

CFS IP Access CGW ADD SR Validation
    [Arguments]    ${item}    ${srState}    ${relatedItems}
    [Documentation]    Validates the information stored in SR
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

CFS IP Access CGW ADD Cancel Project Validation
    [Arguments]    ${item}    ${taiName}
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    ${API_OPERATION}[CANCEL_PROJECT]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    # Validate Project Key
    ${projectKey}    Get Service Item Characteristic    ${item}    eaiProjectKey
    XML Validate Element by Value    ${request_xml}    //projectKey/keyValue/text()    ${projectKey}