*** Settings ***
Resource          ../../XML/xml.robot
Library           JSONLibrary
Library           String
Resource          ../../Json/json.robot
Resource          ../../Csv/csv.robot

*** Variables ***
${WORKSPACE}

*** Variables ***
&{actualToFeasibleBWMappingFTTH}    1000000=500000    524000=500000    220000=200000    100000=100000    51200=50000    100=100    # infotable for actualToFeasibleBWMappingFTTH
&{DeliveryTimeFTTH}    6=5    11=14    # nlType=expectedDeliveryDays - for FTTH

*** Keywords ***
Validate Existing Fiber Line
    [Arguments]    ${acpeResponse}    ${sqmResponse}
    [Documentation]    Validate the place containers in the sqm response
    ...
    ...    - ExistingFiberLine
    #Get expected delivery days
    ${nlType}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.technologyType=='GoF')].networkDetails.NL-type
    #Get Expected Delivery Days Based on nl type
    ${expectedDeliveryDaysCSV}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/expectedDeliveryDays.csv
    ${filteredRow}    Get expectedDeliveryDays Row from CSV    ${nlType[0]}    CFS_IP_ACCESS_WBA_FTTH    ExistingFiberLine    ${expectedDeliveryDaysCSV}
    #Get Delivery Time
    ${expectedDeliverDays}    Set Variable    ${filteredRow[3]}
    #Get house number
    ${houseNum}    Get Value From Json    ${acpeResponse}    $.houseNumber
    ${houseNum}    convert to string    ${houseNum[0]}
    #Validate @type
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[?(@.accessServiceId)][@type]    ExistingFiberLine
    #Validate role
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[?(@.accessServiceId)][role]    connectionPointOption
    #Validate Postcode
    ${postCode}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][postcode]
    JSON Validate Element by Value    ${acpeResponse}    $.zipCode    ${postCode[0].replace(" ","")}
    #Validate HouseNumber
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[?(@.accessServiceId)][houseNumber]    ${houseNum}
    #Validate ConnectionPointSpec
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[?(@.accessServiceId)][connectionPointIdentifier]    nvt
    #Validate Expected Delivery Date
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[?(@.accessServiceId)][expectedDeliveryDays]    ${expectedDeliverDays}
    #Get acess service id
    ${accessServiceId}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.networkType=='FTTH')].lineInformations[0].services[0].serviceId
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[?(@.accessServiceId)].accessServiceId    ${accessServiceId[0]}
    #Get Patchless possible
    ${patchless}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.networkType=='FTTH')].lineInformations[0].services[0].patchless
    ${patchless}    Convert To Boolean    ${patchless[0]}
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[?(@.accessServiceId)].patchlessPossible    ${patchless}

Validate ACPE Feasible Bandwidth FTTH
    [Arguments]    ${acpeResponse}    ${sqmResponse}
    [Documentation]    Validate the feasible bandwidth calculation for Fiber
    #Get Actual bandwidth Down
    ${actualBW_Down}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.technologyType =='GoF')].maxBandwithDownOriginal
    ${actualBW_Down}    Evaluate    ${actualBW_Down[0]} / 1024
    ${actualBW_Down}    Convert To Integer    ${actualBW_Down}
    ${actualBW_Down}    Convert To String    ${actualBW_Down}
    #Get Actual bandwidth Up
    ${actualBW_Up}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.technologyType =='GoF')].maxBandwithUpOriginal
    ${actualBW_Up}    Evaluate    ${actualBW_Up[0]} / 1024
    ${actualBW_Up}    Convert To Integer    ${actualBW_Up}
    ${actualBW_Up}    Convert To String    ${actualBW_Up}
    #Calculate Feasible Bandwidths
    ${feasibleBW_Down}    Set Variable    ${actualBW_Down}
    ${feasibleBW_Up}    Set Variable    ${actualBW_Up}
    #Validate the calculated Feasible Bandwidth Against the BW returned in the Feasibility Response
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.serviceCharacteristic[?(@.name=='bandwidthDown')].value    ${feasibleBW_Down}
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.serviceCharacteristic[?(@.name=='bandwidthUp')].value    ${feasibleBW_Up}

Validate ACPE Feasible Bandwidth GOP FTTH
    [Arguments]    ${acpeResponse}    ${sqmResponse}    ${serviceSpecificationName}
    [Documentation]    Validate the feasible bandwidth calculation for Fiber
    #Get Actual bandwidth Down
    ${actualBW_Down}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.technologyType =='XGSPON')].maxBandwithDownOriginal
    ${actualBW_Down}    Evaluate    ${actualBW_Down[0]} / 1024
    ${actualBW_Down}    Convert To Integer    ${actualBW_Down}
    ${actualBW_Down}    Convert To String    ${actualBW_Down}
    #Get Actual bandwidth Up
    ${actualBW_Up}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.technologyType =='XGSPON')].maxBandwithUpOriginal
    ${actualBW_Up}    Evaluate    ${actualBW_Up[0]} / 1024
    ${actualBW_Up}    Convert To Integer    ${actualBW_Up}
    ${actualBW_Up}    Convert To String    ${actualBW_Up}
    #Calculate Feasible Bandwidths
    ${feasibleBW_Down}    Set Variable    ${actualBW_Down}
    ${feasibleBW_Up}    Set Variable    ${actualBW_Up}
    #Validate the calculated Feasible Bandwidth Against the BW returned in the Feasibility Response
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='${serviceSpecificationName}')].service.serviceCharacteristic[?(@.name=='bandwidthDown')].value    ${feasibleBW_Down}
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='${serviceSpecificationName}')].service.serviceCharacteristic[?(@.name=='bandwidthUp')].value    ${feasibleBW_Up}

Validate Available Fiber Line
    [Arguments]    ${acpeResponse}    ${sqmResponse}
    [Documentation]    Validate the place containers in the sqm response
    ...    - AvailableFiberLine
    #Get expected delivery days
    ${nlType}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.technologyType=='GoF')].networkDetails.nlType
    #Get Expected Delivery Days Based on nl type
    ${expectedDeliveryDaysCSV}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/expectedDeliveryDays.csv
    ${filteredRow}    Get expectedDeliveryDays Row from CSV    ${nlType[0]}    CFS_IP_ACCESS_WBA_FTTH    AvailableFiberLine    ${expectedDeliveryDaysCSV}
    #Get Delivery Time
    ${expectedDeliverDays}    Set Variable    ${filteredRow[3]}
    #Get house number
    ${houseNum}    Get Value From Json    ${acpeResponse}    $.houseNumber
    ${houseNum}    convert to string    ${houseNum[0]}
    #Validate @type
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][@type]    AvailableFiberLine
    #Validate role
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][role]    connectionPointOption
    #Validate Postcode
    ${postCode}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][postcode]
    JSON Validate Element by Value    ${acpeResponse}    $.zipCode    ${postCode[0].replace(" ","")}
    #Validate HouseNumber
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][houseNumber]    ${houseNum}
    #Validate ConnectionPointSpec
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][connectionPointIdentifier]    nvt
    #Validate Expected Delivery Date
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][expectedDeliveryDays]    ${expectedDeliverDays}

Validate GOP Line Status For Existing Line
    [Arguments]    ${acpeResponse}  
    ${lineStatus}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[0].lineInformations[0].lineOccupied
    Run Keyword If  "${lineStatus}[0]" == "OccupiedByOther" or "${lineStatus}[0]" == "OccupiedByUs" or "${lineStatus}[0]" == "Occupied"  Log to Console  Line Is ${lineStatus}[0]
    ...  ELSE   Fail  No Line Occupied  
