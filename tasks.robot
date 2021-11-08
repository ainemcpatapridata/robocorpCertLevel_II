# ## Certificate level II: 
#  <a href="https://https://robocorp.com/docs/courses/build-a-robot">Build a robot</a>.
*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.Robocorp.Vault
Library    Dialogs

*** Keywords ***
Download Orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True    target_file=${CURDIR}${/}output${/}

Open Page
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Create Receipt
    [Arguments]    ${data}
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${CURDIR}${/}output${/}receipts${/}receipt_${data}[Order number].pdf
    Capture Element Screenshot      id:robot-preview-image    ${CURDIR}${/}output${/}imgs${/}img_${data}[Order number].png
    Add Watermark Image To Pdf    ${CURDIR}${/}output${/}imgs${/}img_${data}[Order number].png    ${CURDIR}${/}output${/}receipts${/}receipt_${data}[Order number].pdf    ${CURDIR}${/}output${/}receipts${/}receipt_${data}[Order number].pdf


Fill Form And Submit
    [Arguments]    ${data}
    Click Element    //button[@class="btn btn-dark"]
    Select From List By Value    //select[@name="head"]    ${data}[Head]
    Click Element    //label[@for="id-body-${data}[Body]"]
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${data}[Legs]
    Input Text    //input[@name="address"]    ${data}[Address]
    Click Button    id:preview

    Click Element    //button[@id="order"]
    FOR    ${i}    IN RANGE    0    100
        ${sucessfullyOrdered}=    Is element visible    //button[@id="order-another"]
        Exit For Loop If    ${sucessfullyOrdered} == True
        Click Element    //button[@id="order"]
    END

    Wait Until Element Is Visible    id:receipt 
    Wait Until Element Is Visible    id:robot-preview-image
    Create Receipt    ${data}
    Click Element    //button[@id="order-another"]


Fill Form With CSV
    @{table}=  Read table from CSV    ${CURDIR}${/}output${/}orders.csv
    FOR    ${data}    IN    @{table}
        Fill Form And Submit    ${data}
    END



*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download Orders
    Open Page
    Fill Form With CSV
    Archive Folder With Zip    ${CURDIR}${/}output${/}receipts    ${CURDIR}${/}output${/}receipts.zip
    ${wantSecret}=    Get Value From User    Want to know a secret? (Enter YES)
    IF    "${wantSecret}" == "YES"
        ${secret}=    Get Secret    notASecret
        Log    My First Pets Name is ${secret}[firstPetsName]
    END
    [Teardown]    Close Browser
