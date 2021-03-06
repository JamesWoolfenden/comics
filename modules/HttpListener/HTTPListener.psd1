# Copyright (c) 2014 Microsoft Corp.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

@{

# Version number of this module.
ModuleVersion = '1.0.1'

# ID used to uniquely identify this module
GUID = '6f6db990-54f3-4a69-a7ea-7d1765289e13'

# Author of this module
Author = 'Steve Lee'

# Company or vendor of this module
CompanyName = 'Microsoft'

# Copyright statement for this module
Copyright = '(c) 2014 Microsoft. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Creates a new HTTP Listener enabling a remote client to execute PowerShell command lines using a simple REST API.'

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(".\HTTPListener.psm1")

# Functions to export from this module
FunctionsToExport = @('Start-HttpListener')

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
ModuleList = @('.\HTTPListener.psm1')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @("REST","HTTP")

        # A URL to the license for this module.
        LicenseUri = 'http://technet.microsoft.com/en-us/cc300389.aspx'

    } # End of PSData hashtable

    FunctionalTests = @("HTTPListener_Tests.ps1")
    TestFrameworkUri = "https://github.com/pester/Pester"

} # End of PrivateData hashtable

}

