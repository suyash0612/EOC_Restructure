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
CFS IP Access VDSL CHA FPI Validation
    [Arguments]    ${item}    ${taiName}
    [Documentation]    Validates FPI Request
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[FPI]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    XML Validate Element by Value    ${request_xml}    //originator/text()    VTEL
    XML Validate Element by Value    ${request_xml}    //recipient/text()    BUBN
    XML Validate Element by Value    ${request_xml}    //messagetype/text()    FPI_WSO
    XML Validate Element by Value    ${request_xml}    //messageversion/text()    26
    #Validate Payload Against the basket item
    ${ConnectionPoint}    Get Service Item Related Entity    ${item}    ConnectionPoint
    ${reference}    Set Variable    ${ConnectionPoint}[reference]
    ${reference}    Split String    ${reference}    :
    ${address}    Split String    ${reference}[0]    -
    XML Validate Element by Value    ${request_xml}    //requested-housenumber/text()    ${address}[1]
    Comment    XML Validate Element by Value    ${request_xml}    //requested-housenrext/text()    ${address}[1]
    #Validate post code
    ${item_postCode}    Replace String    ${address}[0]    ${space}    ${empty}
    ${request_postCode}    Evaluate Xpath    ${request_xml}    //requested-zipcode/text()
    ${request_postCode}    Replace String    ${request_postCode[0]}    ${space}    ${empty}
    Should Be Equal    ${request_postCode}    ${item_postCode}

CFS IP Access VDSL CHA Design and Assign Validation
    [Arguments]    ${order}    ${item}    ${aggregateServices}    ${taiName}
    [Documentation]    Validates EAI Design and Assign request
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[DESIGN_AND_ASSIGN]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    #Validate Customer Id
    ${customer}    Get Order Related Party    ${order}    Customer
    Comment    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'customerId']/stringAttributeValue/text()    ${customer}[reference]
    # Validate Service Order ID
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'orderId']/stringAttributeValue/text()    ${order}[id]
    # Validate Service Instance ID for Order Item
    ${eaiObjectId}    Get Service Item Characteristic    ${item}    eaiObjectId
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/serviceName/text()    ${eaiObjectId}
    # Validate Service Type
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/serviceType/text()    ipaccess:IPAccessService
    # Validate Action
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/action/text()    CHANGE
    #Validate Bandwidth
    ${shapingBandwidthUp}    Get Service Item Characteristic    ${item}    shapingBandwidthUp
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'shapingBandwidthUp']/stringAttributeValue/text()    ${shapingBandwidthUp}
    ${shapingBandwidthDown}    Get Service Item Characteristic    ${item}    shapingBandwidthDown
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'shapingBandwidthDown']/stringAttributeValue/text()    ${shapingBandwidthDown}
    #Validate Local Access Type
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'localAccessType']/stringAttributeValue/text()    WBA_VDSL
    #Validate Access Area
    ${RES_LA_WBA}    Get Resource Item    ${item}    RES_LA_WBA
    ${accessAreaId}    Get Resource Item Characteristic    ${RES_LA_WBA}    accessAreaId
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'accessAreaId']/stringAttributeValue/text()    ${accessAreaId}
    #Validate Service Transport Instance Id
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./groupName/text() = 'serviceInfo' and ./attributeName = 'transportInstanceId']/stringAttributeValue/text()    TI-VTEL/4
    #Validate Management Transport Instance Id
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./groupName/text() = 'managementInfo' and ./attributeName = 'transportInstanceId']/stringAttributeValue/text()    TI-VTEL/14

CFS IP Access VDSL CHA Fetch Validation
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

CFS IP Access VDSL CHA Update Design and Assign Validation
    [Arguments]    ${order}    ${item}    ${taiName}
    [Documentation]    Validates Update Design and Assign request towards EAI
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[UPDATE_DESIGN_AND_ASSIGN]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    #Validate Service Type
    XML Validate Element by Value    ${request_xml}    //serviceType/text()    WBA_VDSL
    #Validate Service Name
    ${serviceName}    Get Service Item Characteristic    ${item}    eaiObjectId
    XML Validate Element by Value    ${request_xml}    //serviceName/text()    ${serviceName}
    #Validate Action
    XML Validate Element by Value    ${request_xml}    //action/text()    CHANGE
    # Validate Service Instance ID
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'serviceInstanceId' and ./groupName/text() = 'serviceSpecification']/stringAttributeValue/text()    ${item}[services][0][serviceId]
    # Validate Order ID
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'orderId']/stringAttributeValue/text()    ${order}[id]
    # Validate Customer ID
    ${customer}    Get Order Related Party    ${order}    Customer
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'customerId']/stringAttributeValue/text()    ${customer}[reference]
    # Validate Carrier Type
    ${RES_LA_WBA}    Get Resource Item    ${item}    RES_LA_WBA
    ${carrierType}    Get Resource Item Characteristic    ${RES_LA_WBA}    carrierType
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'carrierType']/stringAttributeValue/text()    ${carrierType}
    # Validate Technology Type
    ${carrierType}    Get Resource Item Characteristic    ${RES_LA_WBA}    technologyType
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'technologyType']/stringAttributeValue/text()    ${carrierType}
    # Validate Service Group
    ${serviceGroup}    Get Resource Item Characteristic    ${RES_LA_WBA}    serviceGroup
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'serviceGroup']/stringAttributeValue/text()    ${serviceGroup}
    # Validate Carrier Vendor ID
    ${carrierVendorId}    Get Resource Item Characteristic    ${RES_LA_WBA}    carrierVendorId
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'carrierVendorId']/stringAttributeValue/text()    ${carrierVendorId}
    # Validate XDF Access Service ID
    ${xdfAccessServiceId}    Get Resource Item Characteristic    ${RES_LA_WBA}    xdfAccessServiceId
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'xdfAccessServiceId']/stringAttributeValue/text()    ${xdfAccessServiceId}
    # Validate SLA Name
    ${slaName}    Get Resource Item Characteristic    ${RES_LA_WBA}    slaName
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'slaName']/stringAttributeValue/text()    ${slaName}
    # Validate Access Instance ID
    ${accessInstanceId}    Get Resource Item Characteristic    ${RES_LA_WBA}    accessInstanceId
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'accessInstanceId']/stringAttributeValue/text()    ${accessInstanceId}
    #Validate WBA Service Instance Id
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${serviceInstanceId}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    serviceInstanceId
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'serviceInstanceId' and ./groupName/text()='wbaServiceInfo']/stringAttributeValue/text()    ${serviceInstanceId}
    #Validate WBA Service WAP Area
    ${wapArea}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    wapArea
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'wapArea' and ./groupName/text()='wbaServiceInfo']/stringAttributeValue/text()    ${wapArea}
    #Validate WBA Management Instance Id
    ${RES_LA_WBA_MANAGEMENT}    Get Resource Item    ${item}    RES_LA_WBA_MANAGEMENT
    ${serviceInstanceId}    Get Resource Item Characteristic    ${RES_LA_WBA_MANAGEMENT}    serviceInstanceId
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'serviceInstanceId' and ./groupName/text()='wbaManagementInfo']/stringAttributeValue/text()    ${serviceInstanceId}
    #Validate WBA Management WAP Area
    ${wapArea}    Get Resource Item Characteristic    ${RES_LA_WBA_MANAGEMENT}    wapArea
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'wapArea' and ./groupName/text()='wbaManagementInfo']/stringAttributeValue/text()    ${wapArea}

CFS IP Access VDSL CHA NR Radius Configuration Validation
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
    #Validate Agent Remote ID
    ${agent_remote_id}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    agent_remote_id
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='agent_remote_id')].value    ${agent_remote_id}
    #Validate DNS Primary
    ${dns_primary}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    dns_primary
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='dns_primary')].value    ${dns_primary}
    #Validate DNS Secondary
    ${dns_secondary}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    dns_secondary
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='dns_secondary')].value    ${dns_secondary}
    #Validate Framed IP Netmask
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='framed_ip_netmask')].value    255.255.255.255
    #Validate Framed IP Address
    ${framed_ip_address}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    framed_ip_address
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='framed_ip_address')].value    ${framed_ip_address}
    #Validate QOS Profile
    ${qos_profile}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    qos_profile
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='qos_profile')].value    ${qos_profile}
    #Validate Egress Policy Name
    ${egress_policy_name}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    egress_policy_name
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='egress_policy_name')].value    ${egress_policy_name}
    #Validate Ingress Policy Name
    ${ingress_policy_name}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    ingress_policy_name
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='ingress_policy_name')].value    ${ingress_policy_name}
    #Validate Request ID
    ${request_id}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    request_id
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='request_id')].value    ${request_id}
    #Validate Framed Route
    ${framed_route}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    framed_route
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='framed_route')].value    ${framed_route}
    #Validate Virtual Router
    ${virtual_router}    Get Resource Item Characteristic    ${RES_AAA_IP_ACCESS_ACCOUNT}    virtual_router
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='framed_route')].value    ${virtual_router}
    #Validate NED
    ${RFS_IP_ACCESS_AAA}    Get Rfs Item    ${item}    RFS_IP_ACCESS_AAA
    ${ned}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_AAA}    ned
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='ned')].value    ${ned}
    #Validate NEI
    ${nei}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_AAA}    nei
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='nei')].value    ${nei}

CFS IP Access VDSL CHA NR CGW Configuration Validation
    [Arguments]    ${item}    ${taiName}
    [Documentation]    Validates ROM Create Order towards NR
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[NR_CREATE_ORDER]
    ${request_json}    evaluate    json.loads('''${request}''')    json
    #Validate Payload
    ${RFS_IP_ACCESS_CGW}    Get Rfs Item    ${item}    RFS_IP_ACCESS_CGW
    #Validate QOS Shapping
    #Validate Request ID
    ${RES_CGW_QOS_SHAPING}    Get Resource Item    ${item}    RES_CGW_QOS_SHAPING
    ${request_id}    Get Resource Item Characteristic    ${RES_CGW_QOS_SHAPING}    request_id
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/QosShaping")].resource.characteristic[?(@.name=="request_id")].value    ${request_id}
    #Validate CIR
    ${cir}    Get Resource Item Characteristic    ${RES_CGW_QOS_SHAPING}    cir
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/QosShaping")].resource.characteristic[?(@.name=="cir")].value    ${cir}
    #Validate CIR Unit
    ${cir_unit}    Get Resource Item Characteristic    ${RES_CGW_QOS_SHAPING}    cir_unit
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/QosShaping")].resource.characteristic[?(@.name=="cir_unit")].value    ${cir_unit}
    #Validate Maximum Burst Size
    ${maximum_burst_size}    Get Resource Item Characteristic    ${RES_CGW_QOS_SHAPING}    maximum_burst_size
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/QosShaping")].resource.characteristic[?(@.name=="maximum_burst_size")].value    ${maximum_burst_size}
    #Validate Maximum Burst Size Unit
    ${maximum_burst_size_unit}    Get Resource Item Characteristic    ${RES_CGW_QOS_SHAPING}    maximum_burst_size_unit
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/QosShaping")].resource.characteristic[?(@.name=="maximum_burst_size_unit")].value    ${maximum_burst_size_unit}
    #Validate NED
    ${ned}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_CGW}    ned
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/QosShaping")].resource.characteristic[?(@.name=="ned")].value    ${ned}
    #Validate NEI
    ${nei}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_CGW}    nei
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="Cgw/2/QosShaping")].resource.characteristic[?(@.name=="nei")].value    ${nei}

CFS IP Access VDSL CHA Complete Project Validation
    [Arguments]    ${item}    ${taiName}
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[COMPLETE]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    # Validate Project Key
    ${projectKey}    Get Service Item Characteristic    ${item}    eaiProjectKey
    XML Validate Element by Value    ${request_xml}    //projectKey/keyValue/text()    ${projectKey}

CFS IP Access VDSL CHA Cancel Line WBA Validation
    [Arguments]    ${item}    ${taiName}    ${wso_new_line}    ${wso_cancel_line}
    [Documentation]    Validates New Line request towards KPN
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[CANCEL_LINE]
    ${request_xml}    Parse Xml    ${request}
    #Validate Request
    XML Validate Element by Value    ${request_xml}    //originator/text()    VTEL
    XML Validate Element by Value    ${request_xml}    //recipient/text()    BUBN
    XML Validate Element by Value    ${request_xml}    //messagetype/text()    CANCEL_WSO
    XML Validate Element by Value    ${request_xml}    //messageversion/text()    42
    XML Validate Element by Value    ${request_xml}    //order-type/text()    Cancel
    #Validate WSO Id from New Line
    XML Validate Element by Value    ${request_xml}    //original-wso-wo-id/text()    ${wso_new_line}
    #Validate WSO Id from Cancel Line
    XML Validate Element by Value    ${request_xml}    //order-id-wso/text()    ${wso_cancel_line}

CFS IP Access VDSL CHA Cancel Project Validation
    [Arguments]    ${item}    ${taiName}
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[CANCEL_PROJECT]
    ${request_xml}    Parse Xml    ${request}
    #Validate Payload
    # Validate Project Key
    ${projectKey}    Get Service Item Characteristic    ${item}    eaiProjectKey
    XML Validate Element by Value    ${request_xml}    //projectKey/keyValue/text()    ${projectKey}

CFS IP Access VDSL CHA NR IAR Configuration Validation
    [Arguments]    ${item}    ${taiName}
    [Documentation]    Validates ROM Create Order towards NR
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[NR_CREATE_ORDER]
    ${request_json}    evaluate    json.loads('''${request}''')    json
    #Validate Payload
    #Validate PPP Account
    #Validate Request ID
    ${RES_IAR_QOS_SHAPING}    Get Resource Item    ${item}    RES_IAR_QOS_SHAPING
    ${request_id}    Get Resource Item Characteristic    ${RES_IAR_QOS_SHAPING}    request_id
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="AAA/1/QosShaping")].resource.characteristic[?(@.name=="request_id")].value    ${request_id}
    #Validate Username
    ${username}    Get Resource Item Characteristic    ${RES_IAR_QOS_SHAPING}    username
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="AAA/1/QosShaping")].resource.characteristic[?(@.name=="username")].value    ${username}
    #Validate QOS Profile
    ${qosProfile}    Get Resource Item Characteristic    ${RES_IAR_QOS_SHAPING}    qos_profile
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="AAA/1/QosShaping")].resource.characteristic[?(@.name=="qos_profile")].value    ${qosProfile}
    #Validate NED
    ${RFS_IP_ACCESS_IAR}    Get Rfs Item    ${item}    RFS_IP_ACCESS_IAR
    ${ned}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_IAR}    ned
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="AAA/1/QosShaping")].resource.characteristic[?(@.name=="ned")].value    ${ned}
    #Validate NEI
    ${nei}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_IAR}    nei
    JSON Validate Element by Value    ${request_json}    $.orderItem[?(@.resource.name=="AAA/1/QosShaping")].resource.characteristic[?(@.name=="nei")].value    ${nei}

CFS IP Access VDSL CHA SR Validation
    [Arguments]    ${item}    ${srState}
    [Documentation]    Validates the information stored in SR
    ${srService}    Get SR Service    ${item}
    #Validate SR Status
    JSON Validate Element by Value    ${srService}    $.statuses[0].status    ${srState}
    #Validate If serviceBandwidthDown was updated in SR
    #Get item serviceBandwidthDown
    ${servicebandwidthDown}    Get Service Item Characteristic    ${item}    serviceBandwidthDown
    Log    ${servicebandwidthDown}
    JSON Validate Element by Value    ${srService}    $.serviceCharacteristics[?(@.name=='serviceBandwidthDown')].value    ${servicebandwidthDown}
    #Get item serviceBandwidthUp
    ${servicebandwidthUp}    Get Service Item Characteristic    ${item}    serviceBandwidthUp
    JSON Validate Element by Value    ${srService}    $.serviceCharacteristics[?(@.name=='serviceBandwidthUp')].value    ${servicebandwidthUp}
