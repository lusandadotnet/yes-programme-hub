namespace yes.programme;
using { managed, cuid } from '@sap/cds/common';

entity Youth : managed, cuid {
    @PersonalData.IsPotentiallyPersonal
    IDNumber    : String;
    @PersonalData.IsPotentiallyPersonal
    Name        : String;
    StartDate   : Date;
    EndDate     : Date; // Calculated automatically
    Status      : String;
    
    // Relationships
    placement   : Association to Placement;
    monthlyLogs : Composition of many MonthlyLog on monthlyLogs.youth = $self;
    absorption  : Association to Absorption;
}

entity Placement : managed, cuid {
    Department  : String;
    Supervisor  : String;
    CostCenter  : String;
}

entity MonthlyLog : managed, cuid {
    youth       : Association to Youth;
    MonthNumber : Integer;
    Attendance  : Decimal(5,2); // Stored as percentage (e.g., 85.00)
    AppModules  : String;
}

entity Absorption : managed, cuid {
    ContractDate : Date;
    JobTitle     : String;
    SalaryBand   : String;
}