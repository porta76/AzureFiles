page 52101 "Azure File List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Azure Files";
    SourceTableTemporary = true;
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
                            Rec.SetSubPath();
                            Rec.DeleteAll();
                        end;
                        AzureFiles.GetFilesFromShare(Rec);
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
                    AzureFileFunction.GetFilesFromShare(Rec);
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

    var
        [InDataSet]
        IsBold: Boolean;
}