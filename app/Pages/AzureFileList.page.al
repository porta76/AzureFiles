page 52101 "Azure File List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Azure Files";
    SourceTableView = sorting(Type, Name) order(ascending);


    layout
    {
        area(Content)
        {
            repeater(AzureFiles)
            {
                field(Name; rec.Name)
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    StyleExpr = IsBold;

                    trigger OnDrillDown()
                    var
                        AzureFiles: Codeunit "Azure File Functions";
                    begin
                        if Rec.Type = Rec.Type::Directory then begin
                            Rec.SetSubPath(SubPath);
                            Rec.DeleteAll();
                        end;
                        AzureFiles.GetFilesAndDirectoriesFromShare(Rec, Rec.GetSubPath(SubPath));
                    end;
                }
                field(Size; rec.Size)
                {
                    ApplicationArea = All;
                }
                field(Type; rec.Type)
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action("Get Azure Files")
            {
                ApplicationArea = All;
                Image = GetLines;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    AzureFileFunction: Codeunit "Azure File Functions";
                begin
                    Rec.DeleteAll();
                    AzureFileFunction.GetFilesAndDirectoriesFromShare(Rec, rec.GetSubPath(SubPath));
                end;
            }


            action(ShowFilesInImportFolder)
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    AzureFilesSetup: Record "Azure Files Setup";
                    ListOfFiles: List of [Text];
                    Filename: Text;
                    AzureFileFunctions: Codeunit "Azure File Functions";

                begin
                    AzureFilesSetup.findfirst();
                    AzureFileFunctions.GetListOfFilesFromDirectory(AzureFilesSetup."Import Folder", ListOfFiles);
                    foreach Filename in ListOfFiles do
                        Message(StrSubstNo(FileFound, Filename, AzureFilesSetup."Import Folder"));
                end;
            }
            action(DirectImport)
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction();
                var
                    AzureFileFunctions: Codeunit "Azure File Functions";
                begin
                    AzureFileFunctions.ImportFilesUsingXMLport()
                end;
            }
            action(ExportFiles)
            {
                ApplicationArea = All;
                Image = Export;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction();
                var
                    OStream: OutStream;
                    IStream: InStream;
                    TempBlob: Codeunit "Temp Blob";
                    Filename: Text;
                begin
                    TempBlob.CreateOutStream(OStream);
                    Xmlport.Export(52100, OStream, Rec);
                    TempBlob.CreateInStream(IStream);
                    Filename := 'demo.xml';
                    DownloadFromStream(IStream, '', '', '*.*', Filename);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if rec.Type = rec.Type::Directory then
            IsBold := true
        else
            IsBold := false;
    end;

    trigger OnOpenPage()
    begin
        rec.DeleteAll();
        Clear(SubPath);
    end;

    var
        [InDataSet]
        IsBold: Boolean;
        SubPath: List of [Text];
        FileFound: Label 'File %1 found in import folder %2';
}