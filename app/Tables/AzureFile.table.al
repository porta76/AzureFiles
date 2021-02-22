table 52101 "Azure Files"
{
    DataClassification = CustomerContent;

    fields
    {
        field(10; Name; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(20; Type; Enum "Azure File Types")
        {
            DataClassification = ToBeClassified;
        }
        field(30; Size; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; Name, "Type")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

}