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

Validate ISPorderID
    [Arguments]  ${tmtOperations}
    ${tmtMessageNewOrder}  get value from json  ${tmtOperations}  $[?(@.interfaceOperation=='newOrder')]
    log  ${tmtMessageNewOrder[0]['id']}
    ${messageDetails}  Get message log through API  ${tmtMessageNewOrder[0]['id']}  O
    log  ${messageDetails['sentData']}
    ${sentData}  set variable  ${messageDetails['sentData']}
    ${sentData}  evaluate    json.loads(r'''${sentData}''')    json
    ${ispOrderId}  set variable  ${sentData['ispOrderId']}
    ${tmtMessageRecieved}  get value from json  ${tmtOperations}  $[?(@.interfaceOperation=='readOrderByIspOrderId')]
    log  ${tmtMessageRecieved[0]['id']}
    ${messageDetails}  Get message log through API  ${tmtMessageRecieved[0]['id']}  I
    log  ${messageDetails['receivedData']}
    ${recievedData}  set variable  ${messageDetails['receivedData']}
    ${recievedData}  evaluate    json.loads(r'''${recievedData}''')    json
    ${ispOrderIdRecievedData}  set variable  ${recievedData['ispOrderId']}
    should be equal  ${ispOrderId}  ${ispOrderIdRecievedData}
 
Validate the stateTransitions from TMT before ONT activation
    [Arguments]  ${tmtOperations}
    ${tmtMessageNewOrder}  get value from json  ${tmtOperations}  $[?(@.interfaceOperation=='readOrderByIspOrderId')]
    log  ${tmtMessageNewOrder[0]['id']}
    ${messageDetails}  Get message log through API  ${tmtMessageNewOrder[0]['id']}  I
    log  ${messageDetails['receivedData']}
    ${recievedData}  set variable  ${messageDetails['receivedData']}
    ${recievedData}  evaluate    json.loads(r'''${recievedData}''')    json
    # should be equal  "Accepted"  "${recievedData['orderProducts'][0]['state']}"


Validate ONT sent data from TMT 
    [Arguments]  ${tmtOperations}  ${ontValue}
    log  ${tmtOperations}
    ${tmtMessageRegisterOnt}  get value from json  ${tmtOperations}  $[?(@.interfaceOperation=='registerOnt')]
    log  ${tmtMessageRegisterOnt[0]['id']}
    ${messageDetails}  Get message log through API  ${tmtMessageRegisterOnt[0]['id']}  O
    log  ${messageDetails['sentData']}
    ${sentData}  evaluate    json.loads(r'''${messageDetails['sentData']}''')    json
    log  ${sentData}
    should be equal  ${sentData['ontSerialNumber']}  ${ontValue}


Validate the stateTransitions from TMT after ONT activation
    [Arguments]  ${tmtOperations}
    ${tmtMessageNewOrder}  get value from json  ${tmtOperations}  $[?(@.interfaceOperation=='readOrderByIspOrderId')]
    log  ${tmtMessageNewOrder}
    log  ${tmtMessageNewOrder[0]['id']}
    ${messageDetails}  Get message log through API  ${tmtMessageNewOrder[2]['id']}  I
    log  ${messageDetails['receivedData']}
    ${recievedData}  set variable  ${messageDetails['receivedData']}
    ${recievedData}  evaluate    json.loads(r'''${recievedData}''')    json
    # should be equal  "InService"  "${recievedData['orderProducts'][0]['state']}"

Get patchOrder details  
    [Arguments]  ${orderId}
    sleep  10s
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #fetch basketItemId
    ${basketItemId}  Get BasketItem id from order id  ${orderId}  CFS_IP_ACCESS_GOP_FTTH
    log  ${basketItemId}
    #get gop connection id
    ${response}    Get Request    OM Get Order    /eoc/om/v1/order/${orderId}/pooi/${basketItemId}    headers=${header}
    log  ${response.json()['serviceCharacteristics']}
    ${gopConnectionId}  get value from json  ${response.json()['serviceCharacteristics']}  $[?(@.name=='gopConnectionId')]
    log  ${gopConnectionId[0]}
    Create Session    tecloSysHost    ${tecloSysHost}
    ${patchOrderDetails}    Get Request    tecloSysHost    /api/patch/${gopConnectionId[0]['value']}
    # ${patchOrderDetails}    Get Request    Patch Order    /api/patch/5800756147
    # log   ${patchOrderDetails.json()['patchOrders']['patchOrderId']}
    # ${gopConnectionId}  get value from json  ${patchOrderDetails.json()}  $[?(@.patchOrders=='gopConnectionId')]
    [Return]  ${patchOrderDetails.json()['patchOrders'][0]['patchOrderId']}

Set the status to complete in GoBoss
    [Arguments]  ${patchOrderId}
    ${currentDate}    Get Current Date    result_format=%Y-%m-%d
    log  ${currentDate}
    ${requestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/goBossStatusComplete.json
    Update Value To Json  ${requestBody}  $..completeDt  ${currentDate}T08:11:36.261Z
    log  ${requestBody}
    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
    Create Session  gridzHost  ${gridzHost}
    ${headers}  Create Dictionary  Content-Type=application/json
    ${patchOrderDetails}    Post Request  gridzHost  /api/stub/tasks/${patchOrderId}  data=${requestBody}  headers=${headers}


Set the status to Disconnect in GoBoss
    [Arguments]  ${patchOrderId}
    ${currentDate}    Get Current Date    result_format=%Y-%m-%d
    log  ${currentDate}
    ${requestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/goBossStatusDisconnect.json
    Update Value To Json  ${requestBody}  $..completeDt  ${currentDate}T08:11:36.261Z
    log  ${requestBody}
    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
    Create Session  gridzHost  ${gridzHost}
    ${headers}  Create Dictionary  Content-Type=application/json
    ${patchOrderDetails}    Post Request  gridzHost  /api/stub/tasks/${patchOrderId}  data=${requestBody}  headers=${headers}


Trigger the status Update   
    sleep  10
    Create Session    tecloSysHost    ${tecloSysHost}   
    ${data}  Create Dictionary  Name=ProcessSignalsBackgroundService
    ${headers}  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}  Post Request  tecloSysHost  /BackgroundServices/Trigger  data=${data}  headers=${headers}


Get an array with all VWT patch Orders
    sleep  10
    Create Session    vwtHost    ${vwtHost}   
    ${response}    Get Request    vwtHost  /api/stubdata/patchorderstate    
    log  ${response.json()[0]['orderId']}
    [Return]  ${response.json()[0]['orderId']}

Change the delivery state
    [Arguments]  ${operatorOrderId}  ${tcName}
    Create Session    vwtHost    ${vwtHost}
    ${requestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/patchOrderStatus.json
    ${response}    Post Request    vwtHost  /api/stubdata/patchorderstate/${operatorOrderId}  
    sleep  10


CFS IP Access CGW ADD Design and Assign Validation for GoP
    [Arguments]    ${order}    ${item}    ${related_ip_access_item}    ${taiName}  ${CFS_CGW}
    [Documentation]    Validates EAI Design and Assign request
    log  ${item}
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
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'rfsInstanceId']/stringAttributeValue/text()    ${item}[serviceId]
    # Validate Service Instance ID for Order Item
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/serviceName/text()    ${item}[serviceId]
    # Validate Service Type
    XML Validate Element by Value    ${request_xml}    //provisioningOrderItem/serviceType/text()    ipaccess:RfsCgw
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
    ${vendor}    Get Service Item Characteristic    ${CFS_CGW}    vendor
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'vendor']/stringAttributeValue/text()    ${vendor}
    #Validate Model
    ${model}    Get Service Item Characteristic    ${CFS_CGW}    model
    XML Validate Element by Value    ${request_xml}    //dynamicAttribute[./attributeName/text() = 'model']/stringAttributeValue/text()    ${model}

  