page 52100 "Azure File Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Azure Files Setup";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Account"; rec."Account")
                {
                    ApplicationArea = All;

                }
                field("Root Share"; rec."Root Share")
                {
                    ApplicationArea = All;

                }
                field("Sas Token"; rec."Sas Token")
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }
}