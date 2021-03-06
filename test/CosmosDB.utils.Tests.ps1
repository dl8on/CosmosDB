[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$ModuleManifestName = 'CosmosDB.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"

Import-Module -Name $ModuleManifestPath -Force

InModuleScope CosmosDB {
    # Variables for use in tests
    $script:testAccount = 'testAccount'
    $script:testDatabase = 'testDatabase'
    $script:testKey = 'GFJqJeri2Rq910E0G7PsWoZkzowzbj23Sm9DUWFC0l0P8o16mYyuaZKN00Nbtj9F1QQnumzZKSGZwknXGERrlA=='
    $script:testKeySecureString = ConvertTo-SecureString -String $script:testKey -AsPlainText -Force
    $script:testEmulatorKey = 'C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=='
    $script:testBaseUri = 'documents.contoso.com'
    $script:testDate = (Get-Date -Year 2017 -Month 11 -Day 29 -Hour 10 -Minute 45 -Second 10)
    $script:testUniversalDate = 'Tue, 28 Nov 2017 21:45:10 GMT'
    $script:testContext = [CosmosDb.Context] @{
        Account  = $script:testAccount
        Database = $script:testDatabase
        Key      = $script:testKeySecureString
        KeyType  = 'master'
        BaseUri  = ('https://{0}.documents.azure.com/' -f $script:testAccount)
    }
    $script:testJson = @'
{
    "_rid": "2MFbAA==",
    "Users": [
        {
            "id": "testUser"
        }
    ],
    "_count": 1
}
'@
    $script:testResourceGroup = 'testResourceGroup'

    Describe 'Custom types' -Tag 'Unit' {
        Context 'CosmosDB.Context' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.Context').Type | Should -Be $True
            }
        }
        Context 'CosmosDB.IndexingPolicy.Policy' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.IndexingPolicy.Policy').Type | Should -Be $True
            }
        }
        Context 'CosmosDB.IndexingPolicy.Path.Index' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.IndexingPolicy.Path.Index').Type | Should -Be $True
            }
        }
        Context 'CosmosDB.IndexingPolicy.Path.IncludedPath' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.IndexingPolicy.Path.IncludedPath').Type | Should -Be $True
            }
        }
        Context 'CosmosDB.IndexingPolicy.Path.ExcludedPath' {
            It 'Should exist' {
                ([System.Management.Automation.PSTypeName]'CosmosDB.IndexingPolicy.Path.ExcludedPath').Type | Should -Be $True
            }
        }
    }

    Describe 'New-CosmosDbContext' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbContext -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with Context parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account  = $script:testAccount
                    Database = $script:testDatabase
                    Key      = $script:testKeySecureString
                    KeyType  = 'master'
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.Key | Should -Be $script:testKeySecureString
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
            }
        }

        Context 'When called with Azure parameters and not connected to Azure' {
            $script:result = $null

            Mock -CommandName Get-AzureRmContext -MockWith { throw }
            Mock -CommandName Add-AzureRmAccount
            Mock `
                -CommandName Invoke-AzureRmResourceAction `
                -MockWith { @{
                    primaryMasterKey           = 'primaryMasterKey'
                    secondaryMasterKey         = 'secondaryMasterKey'
                    primaryReadonlyMasterKey   = 'primaryReadonlyMasterKey'
                    secondaryReadonlyMasterKey = 'secondaryReadonlyMasterKey'
                } }

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account       = $script:testAccount
                    Database      = $script:testDatabase
                    ResourceGroup = $script:testResourceGroup
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Invoke-AzureRmResourceAction -Exactly -Times 1
                Assert-MockCalled -CommandName Get-AzureRmContext -Exactly -Times 1
                Assert-MockCalled -CommandName Add-AzureRmAccount -Exactly -Times 1
            }
        }

        Context 'When called with Azure parameters and connected to Azure' {
            $script:result = $null

            Mock `
                -CommandName Invoke-AzureRmResourceAction `
                -MockWith { @{
                    primaryMasterKey           = 'primaryMasterKey'
                    secondaryMasterKey         = 'secondaryMasterKey'
                    primaryReadonlyMasterKey   = 'primaryReadonlyMasterKey'
                    secondaryReadonlyMasterKey = 'secondaryReadonlyMasterKey'
                } }

            Mock -CommandName Get-AzureRmContext -MockWith { $true  }
            Mock -CommandName Add-AzureRmAccount

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Account       = $script:testAccount
                    Database      = $script:testDatabase
                    ResourceGroup = $script:testResourceGroup
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be $script:testAccount
                $script:result.Database | Should -Be $script:testDatabase
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
            }

            It 'Should call expected mocks' {
                Assert-MockCalled -CommandName Invoke-AzureRmResourceAction -Exactly -Times 1
                Assert-MockCalled -CommandName Get-AzureRmContext -Exactly -Times 1
                Assert-MockCalled -CommandName Add-AzureRmAccount -Exactly -Times 0
            }
        }

        Context 'When called with Emulator parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbContextParameters = @{
                    Database = $script:testDatabase
                    Emulator = $true
                }

                { $script:result = New-CosmosDbContext @newCosmosDbContextParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result.Account | Should -Be 'localhost'
                $script:result.Database | Should -Be $script:testDatabase
                $tempCredential = New-Object System.Net.NetworkCredential("TestUsername", $result.Key, "TestDomain")
                $tempCredential.Password | Should -Be $script:testEmulatorKey
                $script:result.KeyType | Should -Be 'master'
                $script:result.BaseUri | Should -Be ('https://localhost:8081/')
            }
        }
    }

    Describe 'Get-CosmosDbUri' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Get-CosmosDbUri -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with Account parameter only' {
            $script:result = $null

            It 'Should not throw exception' {
                $GetCosmosDbUriParameters = @{
                    Account = $script:testAccount
                }

                { $script:result = Get-CosmosDbUri @GetCosmosDbUriParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType uri
                $script:result.ToString() | Should -Be ('https://{0}.documents.azure.com/' -f $script:testAccount)
            }
        }

        Context 'When called with Account and BaseUri parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $GetCosmosDbUriParameters = @{
                    Account = $script:testAccount
                    BaseUri = $script:testBaseUri
                }

                { $script:result = Get-CosmosDbUri @GetCosmosDbUriParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -BeOfType uri
                $script:result.ToString() | Should -Be ('https://{0}.{1}/' -f $script:testAccount, $script:testBaseUri)
            }
        }
    }

    Describe 'ConvertTo-CosmosDbTokenDateString' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name ConvertTo-CosmosDbTokenDateString -ErrorAction Stop } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $convertToCosmosDBTokenDateStringParameters = @{
                    Date = $script:testDate
                }

                { $script:result = ConvertTo-CosmosDbTokenDateString @convertToCosmosDBTokenDateStringParameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result | Should -Be $script:testDate.ToUniversalTime().ToString("r", [System.Globalization.CultureInfo]::InvariantCulture)
            }
        }
    }

    Describe 'New-CosmosDbAuthorizationToken' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name New-CosmosDbAuthorizationToken } | Should -Not -Throw
        }

        Context 'When called with all parameters' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbAuthorizationTokenParameters = @{
                    Key          = $script:testKeySecureString
                    KeyType      = 'master'
                    Method       = 'Get'
                    ResourceType = 'users'
                    ResourceId   = 'dbs/testdb'
                    Date         = $script:testUniversalDate
                }

                { $script:result = New-CosmosDbAuthorizationToken @newCosmosDbAuthorizationTokenParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result | Should -Be 'type%3dmaster%26ver%3d1.0%26sig%3dr3RhzxX7rv4ZHqo4aT1jDszfV7svQ7JFXoi7hz1Iwto%3d'
            }
        }

        Context 'When called with all parameters and mixed case ResourceId' {
            $script:result = $null

            It 'Should not throw exception' {
                $newCosmosDbAuthorizationTokenParameters = @{
                    Key          = $script:testKeySecureString
                    KeyType      = 'master'
                    Method       = 'Get'
                    ResourceType = 'users'
                    ResourceId   = 'dbs/Testdb'
                    Date         = $script:testUniversalDate
                }

                { $script:result = New-CosmosDbAuthorizationToken @newCosmosDbAuthorizationTokenParameters } | Should -Not -Throw
            }

            It 'Should return expected result when' {
                $script:result | Should -Be 'type%3dmaster%26ver%3d1.0%26sig%3dncZem2Awq%2b0LkrQ7mlwJePX%2f2qyEPG3bQDrnuedrjZU%3d'
            }
        }
    }

    Describe 'Invoke-CosmosDbRequest' -Tag 'Unit' {
        It 'Should exist' {
            { Get-Command -Name Invoke-CosmosDbRequest -ErrorAction Stop } | Should -Not -Throw
        }

        BeforeEach {
            Mock -CommandName Get-Date -MockWith { $script:testDate }
        }

        $invokeRestMethod_mockwith = {
            ConvertFrom-Json -InputObject $script:testJson
        }

        Context 'When called with context parameter and Get method and ResourceType is ''users''' {
            $invokeRestMethod_parameterfilter = {
                $Method -eq 'Get' -and `
                $ContentType -eq 'application/json' -and `
                $Uri -eq ('{0}dbs/{1}/{2}' -f $script:testContext.BaseUri,$script:testContext.Database,'users')
            }

            Mock `
                -CommandName Invoke-RestMethod `
                -ParameterFilter $invokeRestMethod_parameterfilter `
                -MockWith $invokeRestMethod_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Get'
                    ResourceType = 'users'
                }

                { $script:result = Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-RestMethod `
                    -ParameterFilter $invokeRestMethod_parameterfilter `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and Get method and ResourceType is ''dbs''' {
            $invokeRestMethod_parameterfilter = {
                $Method -eq 'Get' -and `
                $ContentType -eq 'application/json' -and `
                $Uri -eq ('{0}{1}' -f $script:testContext.BaseUri,'dbs')
            }

            Mock `
                -CommandName Invoke-RestMethod `
                -ParameterFilter $invokeRestMethod_parameterfilter `
                -MockWith $invokeRestMethod_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Get'
                    ResourceType = 'dbs'
                }

                { $script:result = Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-RestMethod `
                    -ParameterFilter $invokeRestMethod_parameterfilter `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and Get method and ResourceType is ''offers''' {
            $invokeRestMethod_parameterfilter = {
                $Method -eq 'Get' -and `
                $ContentType -eq 'application/json' -and `
                $Uri -eq ('{0}{1}' -f $script:testContext.BaseUri,'offers')
            }

            Mock `
                -CommandName Invoke-RestMethod `
                -ParameterFilter $invokeRestMethod_parameterfilter `
                -MockWith $invokeRestMethod_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Get'
                    ResourceType = 'offers'
                }

                { $script:result = Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-RestMethod `
                    -ParameterFilter $invokeRestMethod_parameterfilter `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }

        Context 'When called with context parameter and Post method' {
            $invokeRestMethod_parameterfilter = {
                $Method -eq 'Post' -and `
                $ContentType -eq 'application/query+json' -and `
                $Uri -eq ('{0}dbs/{1}/{2}' -f $script:testContext.BaseUri,$script:testContext.Database,'users')
            }

            Mock `
                -CommandName Invoke-RestMethod `
                -ParameterFilter $invokeRestMethod_parameterfilter `
                -MockWith $invokeRestMethod_mockwith

            $script:result = $null

            It 'Should not throw exception' {
                $invokeCosmosDbRequestparameters = @{
                    Context      = $script:testContext
                    Method       = 'Post'
                    ResourceType = 'users'
                    ContentType  = 'application/query+json'
                    Body         = '{ "id": "daniel" }'
                }

                { $script:result = Invoke-CosmosDbRequest @invokeCosmosDbRequestparameters } | Should -Not -Throw
            }

            It 'Should return expected result' {
                $script:result._count | Should -Be 1
            }

            It 'Should call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-RestMethod `
                    -ParameterFilter $invokeRestMethod_parameterfilter `
                    -Exactly -Times 1
                Assert-MockCalled -CommandName Get-Date -Exactly -Times 1
            }
        }
    }
}
