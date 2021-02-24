//TODO
codeunit 52100 "Azure File Functions"
{
    procedure GetFilesFromShare(var AzureFileShare: Record "Azure Files")
    var
        AzureFileSetup: Record "Azure Files Setup";
        Client: HttpClient;
        Response: HttpResponseMessage;
        TextResponse: Text;
        XMLDoc: XmlDocument;
        UrlEndPoint: Text;
    begin

        AzureFileSetup.FindFirst();
        AzureFileSetup.TestField(Account);
        AzureFileSetup.TestField("Root Share");
        AzureFileSetup.TestField("Sas Token");

        Client.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');
        UrlEndPoint := StrSubstNo(ShareUrl, AzureFileSetup.Account, AzureFileSetup."Root Share", AzureFileSetup."Sas Token");
        if not Client.get(UrlEndPoint, Response) then
            Error(WebServiceCall_err);

        if not Response.IsSuccessStatusCode then
            Error(WebServiceResponse_err, Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content.ReadAs(TextResponse);
        XmlDocument.ReadFrom(TextResponse, XMLDoc);
        PopulateDirectories(AzureFileShare, XMLDoc);
        PopulateFiles(AzureFileShare, XMLDoc);

    end;


    local procedure PopulateDirectories(var AzureFileShare: Record "Azure Files"; XMLDoc: XmlDocument)
    var
        XMLNodeList: XmlNodeList;
        XMLNode: XmlNode;
        innerXMLNode: XmlNode;
    begin
        XMLDoc.SelectNodes(DirectoryNode, XMLNodeList);
        foreach XMLNode in XMLNodeList do begin
            XMLNode.SelectSingleNode(NameNode, innerXMLNode);
            AzureFileShare.Name := innerXMLNode.AsXmlElement().InnerText();
            AzureFileShare.Type := ENUM::"Azure File Types"::Directory;
            AzureFileShare.Insert();
        end;
    end;


    local procedure PopulateFiles(var AzureFileShare: Record "Azure Files"; XMLDoc: XmlDocument)
    var
        XMLNodeList: XmlNodeList;
        XMLNode: XmlNode;
        innerXMLNode: XmlNode;
    begin
        XMLDoc.SelectNodes(FileNode, XMLNodeList);
        foreach XMLNode in XMLNodeList do begin
            XMLNode.SelectSingleNode(NameNode, innerXMLNode);
            AzureFileShare.Name := innerXMLNode.AsXmlElement().InnerText();
            XMLNode.SelectSingleNode(LengthNode, innerXMLNode);
            evaluate(AzureFileShare.Size, innerXMLNode.AsXmlElement().InnerText());
            AzureFileShare.Type := ENUM::"Azure File Types"::File;
            AzureFileShare.Insert();
        end;
    end;

    var
        ShareUrl: Label 'https://%1.file.core.windows.net/%2%3&restype=directory&comp=list';
        FileNode: Label '//EnumerationResults/Entries/File';
        DirectoryNode: Label '//EnumerationResults/Entries/Directory';
        NameNode: Label 'Name';
        LengthNode: Label 'Properties/Content-Length';
        WebServiceCall_err: Label 'The web service was unable to reach the destination %1';
        WebServiceResponse_err: Label 'The web service returned an error message. Status Code: %1 Description: %2';
}