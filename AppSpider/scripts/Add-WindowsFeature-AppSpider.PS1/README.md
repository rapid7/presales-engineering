## Add-WindowsFeature-AppSpider.PS1

### About
The purpose of this PowerShell script to to set the necessary windows features for both AppSpider Pro and Enterprise. This will help eliminate hunting for that the checkbox and eliminate forgetting a setting by mistake that may keep the whole thing from working.

A detailed tabled of tested OS are located on. https://wiki.corp.rapid7.com/display/DS/AppSpider%3A+Enable+Windows+Features+With+PowerShell


### Usage

Run the file in a PowerShell CLI or paste the commands directly into a PowerShell CLI

### Sample output

Success Restart Needed Exit Code      Feature Result
------- -------------- ---------      --------------
True    No             Success        {Common HTTP Features, Default Document, D...
True    No             Success        {WebDAV Publishing, HTTP Redirection}
True    No             Success        {Custom Logging, Tracing, Logging Tools, O...
True    No             Success        {Dynamic Content Compression}
True    No             Success        {Basic Authentication, IIS Client Certific...
True    No             Success        {IIS 6 Metabase Compatibility, IIS 6 Manag...
True    No             Success        {ASP.NET 4.5, .NET Framework 3.5 (includes...
True    No             Success        {.NET Extensibility 4.5}
True    No             Success        {ISAPI Extensions}
True    No             Success        {ISAPI Filters}
True    No             Success        {ASP.NET 3.5}
True    No             Success        {ASP.NET 4.5}
True    No             NoChangeNeeded {}
True    No             Success        {Message Queuing, Message Queuing Server, ...
True    No             Success        {IIS Management Console}
