using YESProgrammeService as service from '../srv/service';

annotate service.Youth with @(
    UI: {
        // basic header details for the obj page
        HeaderInfo: {
            TypeName: 'Youth Participant',
            TypeNamePlural: 'Youth Participants',
            Title: { Value: Name },
            Description: { Value: IDNumber }
        },
        
        // list report dashboard columns 
        LineItem: [
            { Value: Name, Label: 'Full Name' },
            { Value: IDNumber, Label: 'SA ID Number' },
            { Value: StartDate, Label: 'Start Date' },
            { Value: EndDate, Label: 'End Date' },
            { 
                Value: Status, 
                Label: 'Status',
                Criticality: 3 // color-codes the status indicator
            },
            { 
                Value: isHighRisk, 
                Label: 'High Risk Alert',
                Criticality: 1 // marks risk as red/negative if true
            }
        ],

        // dynamic KPI Headers 
        DataPoint #StatusKPI: {
            Value: Status,
            Title: 'Participant Status'
        },
        
        HeaderFacets: [
            {
                $Type: 'UI.ReferenceFacet',
                Target: '@UI.DataPoint#StatusKPI'
            }
        ],

        // object page structure
        Facets: [
            {
                $Type: 'UI.CollectionFacet',
                Label: 'Participant Details',
                ID: 'ParticipantDetails',
                Facets: [
                    {
                        $Type: 'UI.ReferenceFacet',
                        Target: '@UI.FieldGroup#GeneralInfo',
                        Label: 'General Information'
                    }
                ]
            },
            {
                // links the 12-month  logs to the youth obj page
                $Type: 'UI.ReferenceFacet',
                Target: 'monthlyLogs/@UI.LineItem',
                Label: '12-Month Supervisor Logs'
            }
        ],

        FieldGroup #GeneralInfo: {
            Data: [
                { Value: StartDate },
                { Value: EndDate },
                { Value: isHighRisk }
            ]
        }
    }
);

// defines the table columns for the nested monthly Logs on the object page
annotate service.MonthlyLog with @(
    UI: {
        LineItem: [
            { Value: MonthNumber, Label: 'Month (1-12)' },
            { Value: Attendance, Label: 'Attendance (%)' },
            { Value: AppModules, Label: 'YES App Modules Completed' }
        ]
    }
);