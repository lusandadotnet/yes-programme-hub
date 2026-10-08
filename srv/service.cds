using { yes.programme as my } from '../db/schema';

// secure the service by requiring authentication
@requires: 'authenticated-user'
service YESProgrammeService {
    
    @odata.draft.enabled
    // restrict access based on roles
    @restrict: [
        { grant: ['*'], to: 'YES_Admin' },
        { grant: ['READ'], to: 'YES_Supervisor' } // enforces POPIA masking by preventing edits, bit scrappy
    ]
    entity Youth as select from my.Youth {
        *,
        virtual null as isHighRisk : Boolean
    };
    
    @restrict: [
        { grant: ['*'], to: 'YES_Admin' },
        { grant: ['READ'], to: 'YES_Supervisor' }
    ]
    entity Placement as projection on my.Placement;
    
    @restrict: [
        { grant: ['*'], to: 'YES_Admin' },
        { grant: ['*'], to: 'YES_Supervisor' } // supervisors need log entry access
    ]
    entity MonthlyLog as projection on my.MonthlyLog;
    
    @restrict: [
        { grant: ['*'], to: 'YES_Admin' },
        { grant: ['READ'], to: 'YES_Supervisor' }
    ]
    entity Absorption as projection on my.Absorption;
}