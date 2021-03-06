---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbDocumentResourcePath

## SYNOPSIS

Return the resource path for a document object.

## SYNTAX

```powershell
Get-CosmosDbDocumentResourcePath [-Database] <String> [-CollectionId] <String> [-Id] <String>
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet returns the resource identifier for a document object.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-CosmosDbDocumentResourcePath -Database 'MyDatabase' -CollectionId 'MyNewCollection' -Id 'ac12345'
```

Generate a resource path for document 'ac12345 in collection 'MyNewCollection'
in database 'MyDatabase'.

## PARAMETERS

### -Database

This is the database containing the document.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CollectionId

This is the Id of the collection containing the
document.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

This is the Id of the document.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
