xmlport 52100 "File Imports"
{
    Format = VariableText;
    FormatEvaluate = Legacy;

    schema
    {
        textelement(Root)
        {
            tableelement("Azure Files"; "Azure Files")
            {
                XmlName = 'File';
                fieldelement(Name; "Azure Files".Name)
                {
                }
                fieldelement(Size; "Azure Files".Size)
                {
                }
                fieldelement(Type; "Azure Files".Type)
                {
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }
}