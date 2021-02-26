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
                        AzureFiles.GetFilesFromShare(Rec, Rec.GetSubPath(SubPath));
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
                    AzureFileFunction.GetFilesFromShare(Rec, rec.GetSubPath(SubPath));
                end;
            }

            action(ImportFiles)
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction();
                begin
                    Xmlport.Run(52100, true, true);
                end;
            }
            action(ExportFiles)
            {
                ApplicationArea = All;
                Image = Export;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
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
}