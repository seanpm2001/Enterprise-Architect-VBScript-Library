'[path=\Projects\EA-Matic Scripts]
'[group=EA-Matic]

!INC Local Scripts.EAConstants-VBScript

'
' Script Name: Validate XMI Placeholders
' Author: Geert Bellekens
' Purpose: Check if the option "For all packages, create placeholders for external references" is enabled. If it is not, ask the user if it's OK to re-enable it.
' Date: 2019-05-15
'
'EA-Matic

function EA_FileOpen()
	
	'figure out how many locks he has
	dim xmiPlaceHolderSet
	xmiPlaceHolderSet = isXMIPlaceHoldersSet()
	if not xmiPlaceHolderSet then
		dim result
		result = Msgbox("The option 'For all packages, create placeholders for external references' is not enabled. " & _
				"This can seriously damage the model! Re-Enable?", vbYesNo + vbExclamation, "XMI Placeholders setting")
		if result = vbYes then
			'fix the setting
			fixXMIPlaceholder
			'force user to reload the model
			Repository.CloseFile
		end if
	end if
end function

function fixXMIPlaceholder()
	dim sqlUpdateXMISetting
	sqlUpdateXMISetting = "update usys_system set Value = '1' where Property = 'XMI_ShowMissingItems'"
	Repository.Execute sqlUpdateXMISetting
end function

function isXMIPlaceHoldersSet()
	dim sqlXmiPlaceholder
	sqlXmiPlaceholder = "select s.Value as XmiPlaceHolder from usys_system s where s.Property = 'XMI_ShowMissingItems'"
	dim queryResponse
	queryResponse = Repository.SQLQuery(sqlXmiPlaceholder)
    Dim xDoc 
    Set xDoc = CreateObject( "MSXML2.DOMDocument" )
	xDoc.LoadXML(queryResponse)
	dim xmiPlaceHolderNode
	set xmiPlaceHolderNode = xDoc.SelectSingleNode("//XmiPlaceHolder")
	'return count as integer
	if xmiPlaceHolderNode.Text = "1" then
		isXMIPlaceHoldersSet = true
	else
		isXMIPlaceHoldersSet = false
	end if
end function