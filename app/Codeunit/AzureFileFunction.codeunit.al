codeunit 52100 "Azure File Functions"
{
    procedure GetFilesAndDirectoriesFromShare(var AzureFileShare: Record "Azure Files"; SubPath: Text)
    var
        AzureFileSetup: Record "Azure Files Setup";
        Client: HttpClient;
        Response: HttpResponseMessage;
        TextResponse: Text;
        XMLDoc: XmlDocument;
        UrlEndPoint: Text;
        DownloadInStream: InStream;
    begin

        InitAzure(AzureFileSetup);

        Client.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');

        if AzureFileShare.Type <> AzureFileShare.Type::File then
            UrlEndPoint := StrSubstNo(ShareUrl, AzureFileSetup.Account, AzureFileSetup."Root Share" + SubPath, AzureFileSetup."Sas Token")
        else
            UrlEndPoint := StrSubstNo(DownloadUrl, AzureFileSetup.Account, AzureFileSetup."Root Share" + SubPath, AzureFileShare.Name, AzureFileSetup."Sas Token");

        if not Client.get(UrlEndPoint, Response) then
            Error(WebServiceCall_err);

        if not Response.IsSuccessStatusCode then
            Error(WebServiceResponse_err, Response.HttpStatusCode, Response.ReasonPhrase);

        if AzureFileShare.Type <> AzureFileShare.Type::File then begin
            Response.Content.ReadAs(TextResponse);
            XmlDocument.ReadFrom(TextResponse, XMLDoc);
            InsertDirectoriesIntoAzureFiles(AzureFileShare, XMLDoc);
            InsertFilesIntoAzureFiles(AzureFileShare, XMLDoc);
        end else begin
            Response.Content.ReadAs(DownloadInStream);
            File.DownloadFromStream(DownloadInStream, 'Download file', '', '*.*', AzureFileShare.Name);
        end;
    end;

    procedure GetListOfFilesFromDirectory(SubPath: Text; var ListOfFiles: List of [Text])
    var
        AzureFileSetup: Record "Azure Files Setup";
        Client: HttpClient;
        Response: HttpResponseMessage;
        TextResponse: Text;
        XMLDoc: XmlDocument;
        UrlEndPoint: Text;
        DownloadInStream: InStream;
    begin

        InitAzure(AzureFileSetup);
        Client.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');
        UrlEndPoint := StrSubstNo(ShareUrl, AzureFileSetup.Account, AzureFileSetup."Root Share" + SubPath, AzureFileSetup."Sas Token");

        if not Client.get(UrlEndPoint, Response) then
            Error(WebServiceCall_err);

        if not Response.IsSuccessStatusCode then
            Error(WebServiceResponse_err, Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content.ReadAs(TextResponse);
        XmlDocument.ReadFrom(TextResponse, XMLDoc);
        PopulateFileList(XMLDoc, ListOfFiles);
    end;


    local procedure InsertDirectoriesIntoAzureFiles(var AzureFileShare: Record "Azure Files"; XMLDoc: XmlDocument)
    var
        XMLNodeList: XmlNodeList;
        XMLNode: XmlNode;
        innerXMLNode: XmlNode;
    begin
        XMLDoc.SelectNodes(DirectoryNode, XMLNodeList);
        AzureFileShare.Name := '[..]';
        AzureFileShare.Type := AzureFileShare.Type::Directory;
        AzureFileShare.insert;
        foreach XMLNode in XMLNodeList do begin
            XMLNode.SelectSingleNode(NameNode, innerXMLNode);
            AzureFileShare.Name := innerXMLNode.AsXmlElement().InnerText();
            AzureFileShare.Type := ENUM::"Azure File Types"::Directory;
            AzureFileShare.Insert();
        end;
    end;


    local procedure InsertFilesIntoAzureFiles(var AzureFileShare: Record "Azure Files"; XMLDoc: XmlDocument)
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

    local procedure PopulateFileList(XMLDoc: XmlDocument; var ListOfFiles: List of [Text])
    var
        XMLNodeList: XmlNodeList;
        XMLNode: XmlNode;
        innerXMLNode: XmlNode;
        FileName: Text;
    begin
        XMLDoc.SelectNodes(FileNode, XMLNodeList);
        foreach XMLNode in XMLNodeList do begin
            XMLNode.SelectSingleNode(NameNode, innerXMLNode);
            Filename := innerXMLNode.AsXmlElement().InnerText();
            ListOfFiles.Add(Filename);
        end;
    end;


    procedure ImportFilesUsingXMLport()
    var
        AzureFileSetup: Record "Azure Files Setup";
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        Response: HttpResponseMessage;
        TextResponse: Text;
        XMLDoc: XmlDocument;
        UrlEndPoint: Text;
        DownloadInStream: InStream;
    begin
        TempBlob.CreateInStream(DownloadInStream);
        InitAzure(AzureFileSetup);

        Client.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');
        UrlEndPoint := StrSubstNo(DownloadUrl, AzureFileSetup.Account, AzureFileSetup."Root Share", 'DemoImportFolder/demo.xml', AzureFileSetup."Sas Token");
        if not Client.get(UrlEndPoint, Response) then
            Error(WebServiceCall_err);

        if not Response.IsSuccessStatusCode then
            Error(WebServiceResponse_err, Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content.ReadAs(DownloadInStream);
        Xmlport.Import(Xmlport::"File Imports", DownloadInStream);
    end;

    local procedure InitAzure(var AzureFileSetup: Record "Azure Files Setup")
    begin
        AzureFileSetup.FindFirst();
        AzureFileSetup.TestField(Account);
        AzureFileSetup.TestField("Root Share");
        AzureFileSetup.TestField("Sas Token");
    end;

    var
        ShareUrl: Label 'https://%1.file.core.windows.net/%2%3&restype=directory&comp=list';
        DownloadUrl: Label 'https://%1.file.core.windows.net/%2/%3%4';
        FileNode: Label '//EnumerationResults/Entries/File';
        DirectoryNode: Label '//EnumerationResults/Entries/Directory';
        NameNode: Label 'Name';
        LengthNode: Label 'Properties/Content-Length';
        WebServiceCall_err: Label 'The web service was unable to reach the destination %1';
        WebServiceResponse_err: Label 'The web service returned an error message. Status Code: %1 Description: %2';
}