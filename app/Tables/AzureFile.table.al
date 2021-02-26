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

    procedure GetSubPath(var SubPath: List of [Text]): Text
    var
        Directory: Text;
        subPathToReturn: Text;
    begin
        foreach Directory in SubPath do
            subPathToReturn := subPathToReturn + '/' + Directory;

        exit(subPathToReturn);
    end;

    procedure SetSubPath(var SubPath: List of [Text])
    var
        Directory: Text;
        subPathToReturn: Text;
    begin
        if Rec.Name <> '[..]' then begin
            SubPath.Add(Rec.Name);
        end else
            if SubPath.Count > 0 then
                SubPath.RemoveAt(SubPath.Count);
    end;

}