'[path=\Projects\Project A\A Scripts]
'[group=Atrias Scripts]
' Script Name: DocGenUtil
' Author: Geert Bellekens
' Purpose: serves as library for other scripts for document generation
' Date: 06/07/2015

!INC Local Scripts.EAConstants-VBScript

function addMasterDocument (packageGUID, documentName)
	dim domainName
	dim splittedDocumentName
	splittedDocumentName = Split(documentName)
	domainName = splittedDocumentName(Ubound(splittedDocumentName))
	dim ownerPackage as EA.Package
	set ownerPackage = Repository.GetPackageByGuid(packageGUID)
	dim masterDocumentPackage as EA.Package
	set masterDocumentPackage = ownerPackage.Packages.AddNew(documentName, "package")
	masterDocumentPackage.Update
	masterDocumentPackage.Element.Stereotype = "master document"
	masterDocumentPackage.Alias = domainName
	masterDocumentPackage.Update
	'link to the master template
	dim templateTag as EA.TaggedValue
	for each templateTag in masterDocumentPackage.Element.TaggedValues
		if templateTag.Name = "RTFTemplate" then
			templateTag.Value = "(model document: master template)"
			templateTag.Notes = "Default: (model document: master template)"
			templateTag.Update
			exit for
		end if
	next
	'return
	set addMasterDocument = masterDocumentPackage
end function

'improved version of the addMasterDocumentWithDetails usign the tagged values
function addMasterDocumentWithDetailTags (packageGUID,masterDocumentName,documentAlias,documentName,documentTitle,documentVersion)
	dim ownerPackage as EA.Package
	set ownerPackage = Repository.GetPackageByGuid(packageGUID)
	dim masterDocumentPackage as EA.Package
	set masterDocumentPackage = ownerPackage.Packages.AddNew(masterDocumentName, "package")
	masterDocumentPackage.Update
	masterDocumentPackage.Element.Stereotype = "master document"
	masterDocumentPackage.Update
	'link to the master template
	dim templateTag as EA.TaggedValue
	for each templateTag in masterDocumentPackage.Element.TaggedValues
		select case templateTag.Name 
			case "RTFTemplate" 
				templateTag.Value = "(model document: master template)"
				templateTag.Notes = "Default: (model document: master template)"
			case "ReportAlias"
				templateTag.Value = documentAlias
			case "ReportAuthor"
				templateTag.Value = masterDocumentPackage.Element.Author
			case "ReportName"
				templateTag.Value = documentName
			case "ReportTitle"
				templateTag.Value = documentName
			case "ReportVersion"
				templateTag.Value = documentVersion
		end select
		'save changed
		templateTag.Update
	next
	'return
	set addMasterDocumentWithDetailTags = masterDocumentPackage
end function

function addMasterDocumentWithDetails (packageGUID, documentName,documentVersion,documentAlias)
	dim ownerPackage as EA.Package
	set ownerPackage = Repository.GetPackageByGuid(packageGUID)
	dim masterDocumentPackage as EA.Package
	set masterDocumentPackage = ownerPackage.Packages.AddNew(documentName, "package")
	masterDocumentPackage.Update
	masterDocumentPackage.Element.Stereotype = "master document"
	masterDocumentPackage.Alias = documentAlias
	masterDocumentPackage.Version = documentVersion
	masterDocumentPackage.Update
	'link to the master template
	dim templateTag as EA.TaggedValue
	for each templateTag in masterDocumentPackage.Element.TaggedValues
		if templateTag.Name = "RTFTemplate" then
			templateTag.Value = "(model document: master template)"
			templateTag.Notes = "Default: (model document: master template)"
			templateTag.Update
			exit for
		end if
	next
	'return
	set addMasterDocumentWithDetails = masterDocumentPackage
end function

function addModelDocumentForDiagram(masterDocument,diagram, treepos, template)
	dim diagramPackage as EA.Package
	set diagramPackage = Repository.GetPackageByID(diagram.PackageID)
	addModelDocumentForPackage masterDocument,diagramPackage,diagram.Name & " diagram", treepos, template
end function

function addModelDocumentForPackage(masterDocument,package,name, treepos, template)
	dim modelDocElement as EA.Element
	set modelDocElement = masterDocument.Elements.AddNew(name, "Class")
	'set the position
	modelDocElement.TreePos = treepos
	modelDocElement.StereotypeEx = "model document"
	modelDocElement.Update
	'add tagged values
	dim templateTag as EA.TaggedValue
	for each templateTag in modelDocElement.TaggedValues
		if templateTag.Name = "RTFTemplate" then
			templateTag.Value = template
			templateTag.Notes = "Default: Model Report"
			templateTag.Update
			exit for
		end if
	next
	'add attribute
	dim attribute as EA.Attribute
	set attribute = modelDocElement.Attributes.AddNew(package.Name, "Package")
	attribute.ClassifierID = package.Element.ElementID
	attribute.Update
end function

function addModelDocument(masterDocument, template,elementName, elementGUID, treepos)
	addModelDocumentWithSearch masterDocument, template,elementName, elementGUID, treepos,"ZDG_ElementByGUID"
end function


function addModelDocumentWithSearch(masterDocument, template,elementName, elementGUID, treepos, searchName)
	dim modelDocElement as EA.Element;
	set modelDocElement = masterDocument.Elements.AddNew(elementName, "Class")
	'set the position
	modelDocElement.TreePos = treepos
	modelDocElement.StereotypeEx = "model document"
	modelDocElement.Update
	dim templateTag as EA.TaggedValue
	if len(elementGUID) > 0 then
		for each templateTag in modelDocElement.TaggedValues
			if templateTag.Name = "RTFTemplate" then
				templateTag.Value = template
				templateTag.Notes = "Default: Model Report"
				templateTag.Update
			elseif templateTag.Name = "SearchName" then
				templateTag.Value = searchName
				templateTag.Update
			elseif templateTag.Name = "SearchValue" then
				templateTag.Value = elementGUID
				templateTag.Update
			end if
		next
	else
		'add tagged values
		for each templateTag in modelDocElement.TaggedValues
			if templateTag.Name = "RTFTemplate" then
				templateTag.Value = template
				templateTag.Notes = "Default: Model Report"
				templateTag.Update
				exit for
			end if
		next
		'no GUID provided. Set masterdocument package ID as dummy attribute to make the template work
		dim attribute as EA.Attribute
		set attribute = modelDocElement.Attributes.AddNew(masterDocument.Name, "Package")
		attribute.ClassifierID = masterDocument.Element.ElementID
		attribute.Update
	end if
end function