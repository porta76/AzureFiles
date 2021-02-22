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
                    AzureFiles: Record "Azure Files" temporary;
                begin
                    Rec.DeleteAll();
                    AzureFileFunction.GetFilesFromShare(Rec);
                end;
            }
        }
    }
}