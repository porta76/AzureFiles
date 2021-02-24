table 52100 "Azure Files Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "Account"; text[250])
        {
            DataClassification = CustomerContent;
        }
        field(20; "Root Share"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(30; "Sas Token"; text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Account")
        {
            Clustered = true;
        }
    }
}