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
CFS IP Access FTTH DELETE Design and Assign Validation
    [Arguments]    ${order}    ${item}    ${aggregateServices}    ${taiName}
    [Documentation]    Validates EAI Design and Assign request
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[DESIGN_AND_ASSIGN]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    # Validate Service Instance ID for Order Item
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${objectId}    Get Service Item Characteristic    ${CFS_IP_ACCESS_WBA_FTTH}    eaiObjectId
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/serviceName/text()    ${objectId}
    # Validate Service Type
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/serviceType/text()    ipaccess:IPAccessService
    # Validate Action
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/action/text()    DISCONNECT

CFS IP Access FTTH DELETE Fetch Validation
    [Arguments]    ${item}    ${taiName}
    [Documentation]    Validates Fetch Request towards EAI
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[FETCH]
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

CFS IP Access FTTH DELETE Disconnect Line WBA Validation
    [Arguments]    ${order}    ${item}    ${taiName}
    [Documentation]    Validates Disconnect Line request towards KPN
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[DISCONNECT_LINE]
    ${request_xml}    Parse Xml    ${request}
    #Validate Request
    XML Validate Element by Value    ${request_xml}    //originator/text()    VTEL
    XML Validate Element by Value    ${request_xml}    //recipient/text()    BUBN
    XML Validate Element by Value    ${request_xml}    //messagetype/text()    DISCON_LINE_WSO
    XML Validate Element by Value    ${request_xml}    //messageversion/text()    42
    XML Validate Element by Value    ${request_xml}    //order-type/text()    Disconnect Access
    #Validate Service Group
    ${RES_LA_WBA}    Get Resource Item    ${item}    RES_LA_WBA
    ${serviceGroup}    Get Resource Item Characteristic    ${RES_LA_WBA}    serviceGroup
    XML Validate Element by Value    ${request_xml}    //service-group/text()    ${serviceGroup}

CFS IP Access FTTH DELETE NR Radius Configuration Validation
    [Arguments]    ${item}    ${taiName}
    [Documentation]    Validates ROM Create Order towards NR
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[NR_CREATE_ORDER]
    ${request_json}    evaluate    json.loads('''${request}''')    json
    #Validate Payload
    #Validate Username
    ${RES_AAA_IP_ACCESS_ACCOUNT}    Get Resource Item    ${item}    RES_AAA_IP_ACCESS_ACCOUNT
    ${username}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    username
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='username')].value    ${username}
    #Validate Request ID
    ${request_id}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    request_id
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='request_id')].value    ${request_id}
    #Validate NED
    ${RFS_IP_ACCESS_AAA}    Get Rfs Item    ${item}    RFS_IP_ACCESS_AAA
    ${ned}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_AAA}    ned
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='ned')].value    ${ned}
    #Validate NEI
    ${nei}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_AAA}    nei
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='nei')].value    ${nei}

CFS IP Access FTTH DELETE NR CGW Configuration Validation
    [Arguments]    ${item}    ${taiName}
    [Documentation]    Validates ROM Create Order towards NR
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[NR_CREATE_ORDER]
    ${request_json}    evaluate    json.loads('''${request}''')    json
    #Validate Payload
    #Validate PPP Account
    #Validate Request ID
    ${RES_CGW_PPP_ACCOUNT}    Get Resource Item    ${item}    RES_CGW_PPP_ACCOUNT
    ${request_id}    Get Resource Item Characteristic    ${RES_CGW_PPP_ACCOUNT}    request_id
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/PppAccount")].resource.characteristic[?(@.name=="request_id")].value    ${request_id}
    #Validate NED
    ${RFS_IP_ACCESS_CGW}    Get Rfs Item    ${item}    RFS_IP_ACCESS_CGW
    ${ned}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_CGW}    ned
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/PppAccount")].resource.characteristic[?(@.name=="ned")].value    ${ned}
    #Validate NEI
    ${nei}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_CGW}    nei
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/PppAccount")].resource.characteristic[?(@.name=="nei")].value    ${nei}
    #Validate QOS Shapping
    #Validate Request ID
    ${RES_CGW_QOS_SHAPING}    Get Resource Item    ${item}    RES_CGW_QOS_SHAPING
    ${request_id}    Get Resource Item Characteristic    ${RES_CGW_QOS_SHAPING}    request_id
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/QosShaping")].resource.characteristic[?(@.name=="request_id")].value    ${request_id}
    #Validate NED
    ${ned}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_CGW}    ned
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/QosShaping")].resource.characteristic[?(@.name=="ned")].value    ${ned}
    #Validate NEI
    ${nei}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_CGW}    nei
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/QosShaping")].resource.characteristic[?(@.name=="nei")].value    ${nei}

CFS IP Access FTTH DELETE Complete Project Validation
    [Arguments]    ${item}    ${taiName}
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[COMPLETE]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    # Validate Project Key
    ${projectKey}    Get Service Item Characteristic    ${item}    eaiProjectKey
    XML Validate Element by Value    ${request_xml}    //projectKey/keyValue/text()    ${projectKey}

CFS IP Access FTTH DELETE SR Validation
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
        Should be Equal    ${jsonElement}[0][type]    ParentOf
        Should be Equal    ${jsonElement}[0][service][name]    ${relatedItem}[services][0][cfsSpecification]
    END
